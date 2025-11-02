// This is a Bazel HTTP archive proxy service.
// It intercepts Bazel's download requests, and on a cache miss, it simultaneously
// streams the artifact to the client and saves it to a local filesystem cache.
// On subsequent requests, it serves the artifact directly from the cache.
package main

import (
	"crypto/sha256"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
)

// main is the entry point of the application. It sets up the configuration,
// creates the handler, and starts the HTTP server.
func main() {
	// Define and parse the command-line flag for the cache directory.
	cacheDir := flag.String("directory", "/mnt/bazel-cache/proxy/bazel-cache", "The directory to store cached files.")
	flag.Parse()

	// Ensure the cache directory exists.
	if err := os.MkdirAll(*cacheDir, 0755); err != nil {
		log.Fatalf("FATAL: Failed to create cache directory: %v", err)
	}

	log.Printf("Using cache directory: %s", *cacheDir)

	// Create an instance of our proxy handler, passing it the cache directory.
	handler := &proxyHandler{
		cacheDir: *cacheDir,
	}

	// Register the handler and start the server.
	http.Handle("/", handler)
	log.Println("Listening on :7462...")
	if err := http.ListenAndServe(":7462", nil); err != nil {
		log.Fatalf("FATAL: Server failed: %v", err)
	}
}

// proxyHandler holds the state for our HTTP handler, like the cache directory.
type proxyHandler struct {
	cacheDir string
}

// ServeHTTP is the main request handling method. It decides whether to serve a
// file from cache or to stream a new download.
func (ph *proxyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == "HEAD" {
		w.WriteHeader(http.StatusOK)
		return
	}

	// Reconstruct the original download URL from the request path.
	// Bazel sends the original host and path (e.g., "github.com/user/repo.zip")
	// as the path of the request to the proxy. We prepend "https://" to it.
	if r.URL.Path == "/" {
		http.Error(w, "Request path cannot be empty", http.StatusBadRequest)
		return
	}

	reconstructedPath := "https://" + r.URL.Path[1:]
	if r.URL.RawQuery != "" {
		reconstructedPath += "?" + r.URL.RawQuery
	}
	targetURL := reconstructedPath

	if _, err := url.Parse(targetURL); err != nil {
		log.Printf("ERROR: Invalid reconstructed URL: %s. Error: %v", targetURL, err)
		http.Error(w, "Invalid reconstructed URL in path", http.StatusBadRequest)
		return
	}

	// Use a SHA256 hash of the URL as a stable, unique filename for the cache.
	hash := fmt.Sprintf("%x", sha256.Sum256([]byte(targetURL)))
	cachePath := filepath.Join(ph.cacheDir, hash)

	log.Printf("Handling request for: %s (Cache path: %s)", targetURL, cachePath)

	// Check if the file already exists in our local cache.
	_, err := os.Stat(cachePath)
	if os.IsNotExist(err) {
		// --- CACHE MISS ---
		// The file is not cached. We will download it, streaming it simultaneously
		// to the client's response and a temporary cache file.
		err := ph.downloadAndStream(w, targetURL, cachePath)
		if err != nil {
			// An error during the stream is logged. The client will receive a
			// broken response, which is the expected behavior for a failed download.
			// We can't send a new HTTP error header here because the headers and
			// potentially part of the body have already been sent.
			log.Printf("ERROR: Streaming download failed for %s: %v", targetURL, err)
		}
		// The function handled the entire response, so we return.
		return
	} else if err != nil {
		// An unexpected error occurred when checking the file (e.g., permissions).
		log.Printf("ERROR: Failed to stat cache file %s: %v", cachePath, err)
		http.Error(w, "Failed to check local cache", http.StatusInternalServerError)
		return
	}

	// --- CACHE HIT ---
	// The file exists in the cache, so we serve it directly.
	log.Printf("Serving from cache: %s", cachePath)
	http.ServeFile(w, r, cachePath)
}

// downloadAndStream handles the cache miss case. It downloads the file from the
// target URL while simultaneously writing it to the http.ResponseWriter and a
// temporary file. If successful, the temporary file is moved to the final cache path.
func (ph *proxyHandler) downloadAndStream(w http.ResponseWriter, url, finalCachePath string) error {
	log.Printf("Cache miss. Streaming download from %s", url)

	resp, err := http.Get(url)
	if err != nil {
		// If we can't even start the request, send a Bad Gateway error.
		http.Error(w, "Failed to contact upstream server", http.StatusBadGateway)
		return fmt.Errorf("HTTP GET failed: %w", err)
	}
	defer resp.Body.Close()

	// Before streaming the body, forward headers from the upstream response to our client.
	for key, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}
	// We must write the status code header *before* writing the body.
	w.WriteHeader(resp.StatusCode)

	// If the upstream server returned an error status, we stop here.
	// The client has received the error header and we won't proceed to cache the body.
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("upstream server returned status: %s", resp.Status)
	}

	// Create a temporary file to ensure we only cache complete, successful downloads.
	tempFile, err := os.CreateTemp(ph.cacheDir, "download-*.tmp")
	if err != nil {
		return fmt.Errorf("failed to create temp file: %w", err)
	}
	defer tempFile.Close()

	// Create a MultiWriter. It will write to both the client (w) and the temp file.
	destinations := io.MultiWriter(w, tempFile)

	// Start the streaming copy. Bytes are read from resp.Body and written to both destinations.
	bytesWritten, err := io.Copy(destinations, resp.Body)
	if err != nil {
		os.Remove(tempFile.Name()) // Clean up the failed download.
		return fmt.Errorf("failed during stream copy: %w", err)
	}

	// The download was successful. Atomically move the temp file to its final cache path.
	if err := os.Rename(tempFile.Name(), finalCachePath); err != nil {
		os.Remove(tempFile.Name()) // Clean up if rename fails.
		return fmt.Errorf("failed to move temp file to final location: %w", err)
	}

	log.Printf("Successfully streamed and cached %d bytes to %s", bytesWritten, finalCachePath)
	return nil
}
