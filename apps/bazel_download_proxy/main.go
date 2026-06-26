// Bazel Download Proxy
//
// This is a caching HTTP proxy for Bazel build artifacts and Go modules. It
// intercepts download requests, caches responses locally, and serves
// subsequent requests from the local filesystem cache.
//
// Usage:
//
// The proxy listens on port 7462 by default. Choose an upstream based on the
// path prefix:
//
//	/-/<path>   — Bazel remote downloader: fetches https://<path>
//	/go/<path>  — Go module proxy:        fetches https://proxy.golang.org/<path>
//
// Configure Bazel's downloader config (bazel/downloader_config.txt):
//
//	rewrite (.*) http://localhost:7462/-/$1
//
// Configure the Go module proxy:
//
//	GOPROXY=http://localhost:7462/go
package main

import (
	"bufio"
	"crypto/sha256"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
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

	manifest, err := os.OpenFile(filepath.Join(*cacheDir, "MANIFEST"), os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		log.Fatalf("FATAL: Failed to open MANIFEST: %v", err)
	}

	access, err := os.OpenFile(filepath.Join(*cacheDir, "ACCESS"), os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		log.Fatalf("FATAL: Failed to open ACCESS: %v", err)
	}

	handler := &proxyHandler{
		cacheDir:     *cacheDir,
		manifestFile: manifest,
		accessFile:   access,
	}

	// Register the handler and start the server.
	http.Handle("/", handler)
	log.Println("Listening on :7462...")
	if err := http.ListenAndServe(":7462", nil); err != nil {
		log.Fatalf("FATAL: Server failed: %v", err)
	}
}

// proxyHandler holds the state for our HTTP handler.
type proxyHandler struct {
	cacheDir     string
	manifestFile *os.File
	accessFile   *os.File
	mu           sync.Mutex
}

// ServeHTTP is the main request handling method. It decides whether to serve a
// file from cache or to stream a new download.
func (ph *proxyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == "HEAD" {
		w.WriteHeader(http.StatusOK)
		return
	}

	rawPath := r.URL.Path
	if rawPath == "/" {
		http.Error(w, "Request path cannot be empty", http.StatusBadRequest)
		return
	}

	var targetURL string

	switch {
	case strings.HasPrefix(rawPath, "/_/"):
		ph.handleAdmin(w, r)
		return
	case strings.HasPrefix(rawPath, "/-/"):
		targetURL = "https://" + rawPath[len("/-/"):]
	case strings.HasPrefix(rawPath, "/go/"):
		targetURL = "https://proxy.golang.org/" + rawPath[len("/go/"):]
	default:
		targetURL = "https://" + rawPath[1:]
	}

	if r.URL.RawQuery != "" {
		targetURL += "?" + r.URL.RawQuery
	}

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
	ph.appendAccess(hash)
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

	ph.appendManifest(url, filepath.Base(finalCachePath))
	log.Printf("Successfully streamed and cached %d bytes to %s", bytesWritten, finalCachePath)
	return nil
}

// appendManifest records a cache entry in the MANIFEST file. Read on demand
// by management endpoints.
func (ph *proxyHandler) appendManifest(url, hash string) {
	ph.mu.Lock()
	defer ph.mu.Unlock()
	_, err := fmt.Fprintf(ph.manifestFile, "%d\t%s\t%s\n", time.Now().Unix(), url, hash)
	if err != nil {
		log.Printf("ERROR: Failed to write to MANIFEST: %v", err)
	}
}

// appendAccess records a cache hit in the ACCESS file. Read on demand by
// management endpoints.
func (ph *proxyHandler) appendAccess(hash string) {
	ph.mu.Lock()
	defer ph.mu.Unlock()
	_, err := fmt.Fprintf(ph.accessFile, "%d\t%s\n", time.Now().Unix(), hash)
	if err != nil {
		log.Printf("ERROR: Failed to write to ACCESS: %v", err)
	}
}

// handleAdmin routes management requests under /_/.
func (ph *proxyHandler) handleAdmin(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/_/")
	switch {
	case path == "gc" && r.Method == "DELETE":
		ph.handleGC(w, r)
	case path == "pattern" && r.Method == "DELETE":
		ph.handlePattern(w, r)
	default:
		http.Error(w, "Not found\n", http.StatusNotFound)
	}
}

// handleGC implements DELETE /_/gc?max_age=<duration>[&dry_run=true].
//
// Reads the ACCESS file to determine when each cached entry was last
// accessed. Entries not accessed within the specified duration are deleted.
func (ph *proxyHandler) handleGC(w http.ResponseWriter, r *http.Request) {
	maxAgeStr := r.URL.Query().Get("max_age")
	if maxAgeStr == "" {
		http.Error(w, "max_age is required\n", http.StatusBadRequest)
		return
	}
	maxAge, err := time.ParseDuration(maxAgeStr)
	if err != nil {
		http.Error(w, fmt.Sprintf("invalid max_age: %s\n", err), http.StatusBadRequest)
		return
	}

	dryRun := r.URL.Query().Has("dry_run")
	now := time.Now()

	// Read ACCESS file into a map of hash → latest access time.
	accessPath := filepath.Join(ph.cacheDir, "ACCESS")
	accessMap := make(map[string]int64)
	if f, err := os.Open(accessPath); err == nil {
		defer f.Close()
		s := bufio.NewScanner(f)
		for s.Scan() {
			line := strings.TrimSpace(s.Text())
			if line == "" {
				continue
			}
			parts := strings.SplitN(line, "\t", 2)
			if len(parts) != 2 {
				continue
			}
			ts, err1 := strconv.ParseInt(parts[0], 10, 64)
			if err1 != nil {
				continue
			}
			hash := parts[1]
			if ts > accessMap[hash] {
				accessMap[hash] = ts
			}
		}
	}

	// Read MANIFEST and check each entry.
	manifestPath := filepath.Join(ph.cacheDir, "MANIFEST")
	f, err := os.Open(manifestPath)
	if err != nil {
		http.Error(w, fmt.Sprintf("cannot open MANIFEST: %s\n", err), http.StatusInternalServerError)
		return
	}
	defer f.Close()
	s := bufio.NewScanner(f)
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if line == "" {
			continue
		}
		parts := strings.SplitN(line, "\t", 3)
		if len(parts) < 2 {
			continue
		}
		hash := parts[len(parts)-1]

		lastAccess, ok := accessMap[hash]
		if ok && now.Sub(time.Unix(lastAccess, 0)) <= maxAge {
			continue
		}

		cachePath := filepath.Join(ph.cacheDir, hash)
		if dryRun {
			fmt.Fprintln(w, cachePath)
		} else if err := os.Remove(cachePath); err != nil && !os.IsNotExist(err) {
			errStr := strings.ReplaceAll(err.Error(), "\n", ", ")
			fmt.Fprintf(w, "%s error: %s\n", cachePath, errStr)
		} else {
			fmt.Fprintln(w, cachePath)
		}
	}
}

// handlePattern implements
// DELETE /_/pattern?pattern=<glob>[&max_age=<duration>][&dry_run=true].
//
// Reads the MANIFEST and deletes entries whose URL matches the glob pattern.
// If max_age is set, only entries created longer ago than max_age are deleted.
func (ph *proxyHandler) handlePattern(w http.ResponseWriter, r *http.Request) {
	pattern := r.URL.Query().Get("pattern")
	if pattern == "" {
		http.Error(w, "pattern is required\n", http.StatusBadRequest)
		return
	}

	var minAge time.Duration
	var hasMinAge bool
	if maxAgeStr := r.URL.Query().Get("max_age"); maxAgeStr != "" {
		var err error
		minAge, err = time.ParseDuration(maxAgeStr)
		if err != nil {
			http.Error(w, fmt.Sprintf("invalid max_age: %s\n", err), http.StatusBadRequest)
			return
		}
		hasMinAge = true
	}

	dryRun := r.URL.Query().Has("dry_run")
	now := time.Now()

	manifestPath := filepath.Join(ph.cacheDir, "MANIFEST")
	f, err := os.Open(manifestPath)
	if err != nil {
		http.Error(w, fmt.Sprintf("cannot open MANIFEST: %s\n", err), http.StatusInternalServerError)
		return
	}
	defer f.Close()
	s := bufio.NewScanner(f)
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if line == "" {
			continue
		}
		parts := strings.SplitN(line, "\t", 3)
		if len(parts) != 3 {
			continue
		}
		ts, err1 := strconv.ParseInt(parts[0], 10, 64)
		if err1 != nil {
			continue
		}
		url := parts[1]
		hash := parts[2]

		if !globMatch(pattern, url) {
			continue
		}
		if hasMinAge && now.Sub(time.Unix(ts, 0)) <= minAge {
			continue
		}

		cachePath := filepath.Join(ph.cacheDir, hash)
		if dryRun {
			fmt.Fprintln(w, cachePath)
		} else if err := os.Remove(cachePath); err != nil && !os.IsNotExist(err) {
			errStr := strings.ReplaceAll(err.Error(), "\n", ", ")
			fmt.Fprintf(w, "%s error: %s\n", cachePath, errStr)
		} else {
			fmt.Fprintln(w, cachePath)
		}
	}
}

// globMatch reports whether text matches the glob pattern.
//
// Supported pattern characters:
//
//   - — matches any sequence of non-/ characters
//     ** — matches any sequence of characters (including /)
//     ?  — matches any single non-/ character
//     All other characters match literally.
func globMatch(pattern, text string) bool {
	for len(pattern) > 0 {
		p := pattern[0]
		if p == '*' && len(pattern) > 1 && pattern[1] == '*' {
			rst := pattern[2:]
			for i := 0; i <= len(text); i++ {
				if globMatch(rst, text[i:]) {
					return true
				}
			}
			return false
		}
		if p == '*' {
			rst := pattern[1:]
			for i := 0; i <= len(text); i++ {
				if i < len(text) && text[i] == '/' {
					break
				}
				if globMatch(rst, text[i:]) {
					return true
				}
			}
			return false
		}
		if p == '?' {
			if len(text) == 0 || text[0] == '/' {
				return false
			}
			text = text[1:]
			pattern = pattern[1:]
			continue
		}
		if len(text) == 0 || p != text[0] {
			return false
		}
		text = text[1:]
		pattern = pattern[1:]
	}
	return len(text) == 0
}
