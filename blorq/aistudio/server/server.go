package main

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"sync/atomic"

	"github.com/gorilla/websocket"
)

// Global state for the server
var (
	// upgrader handles the HTTP to WebSocket protocol upgrade.
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true }, // Allow all origins
	}

	// activeExtension holds the single, active WebSocket connection to the Chrome extension.
	activeExtension *websocket.Conn
	connMutex       sync.RWMutex // Protects access to activeExtension

	// pendingRequests maps a request ID to a channel that will receive the final response.
	pendingRequests = make(map[uint64]chan string)
	reqMutex        sync.Mutex // Protects access to pendingRequests

	// requestCounter generates unique IDs for each incoming request.
	requestCounter uint64
)

// --- Structs for JSON marshalling/unmarshalling ---

// ExtensionMessage is the format for messages sent to/from the extension.
type ExtensionMessage struct {
	Type      string      `json:"type"`
	RequestID uint64      `json:"requestId"`
	Message   string      `json:"message,omitempty"`
	Response  string      `json:"response,omitempty"`
	Settings  interface{} `json:"settings,omitempty"`
}

// OpenAIRequest captures the incoming request from the client.
type OpenAIRequest struct {
	Messages []struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	} `json:"messages"`
}

// --- HTTP Handlers ---

// handleWebSocket manages the WebSocket connection from the Chrome extension.
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("WebSocket upgrade failed:", err)
		return
	}
	log.Println("Browser extension connected.")

	// Set the active connection
	connMutex.Lock()
	activeExtension = conn
	connMutex.Unlock()

	// Cleanup when the function returns (i.e., the connection closes)
	defer func() {
		log.Println("Browser extension disconnected.")
		connMutex.Lock()
		activeExtension = nil
		connMutex.Unlock()
		conn.Close()

		// Fail any pending requests
		reqMutex.Lock()
		for id, ch := range pendingRequests {
			close(ch) // Closing the channel signals an error to the waiting handler
			delete(pendingRequests, id)
		}
		reqMutex.Unlock()
	}()

	// Reader loop
	for {
		var msg ExtensionMessage
		if err := conn.ReadJSON(&msg); err != nil {
			log.Printf("Error reading from WebSocket: %v", err)
			break // Exit loop on error
		}
		log.Printf("Received message from extension: %+v", msg)

		if msg.Type == "FINAL_RESPONSE" {
			reqMutex.Lock()
			if ch, ok := pendingRequests[msg.RequestID]; ok {
				ch <- msg.Response // Send response to the waiting handler
				delete(pendingRequests, msg.RequestID)
			}
			reqMutex.Unlock()
		}
	}
}

// handleChatCompletions processes the incoming POST request from the client.
func handleChatCompletions(w http.ResponseWriter, r *http.Request) {
	connMutex.RLock()
	if activeExtension == nil {
		connMutex.RUnlock()
		http.Error(w, `{"error": {"message": "No browser extension connected."}}`, http.StatusServiceUnavailable)
		return
	}
	connMutex.RUnlock()

	// Decode the incoming request
	var req OpenAIRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error": {"message": "Invalid request body."}}`, http.StatusBadRequest)
		return
	}
	if len(req.Messages) == 0 {
		http.Error(w, `{"error": {"message": "No messages in request."}}`, http.StatusBadRequest)
		return
	}
	userMessage := req.Messages[len(req.Messages)-1].Content

	// Prepare for the response from the extension
	requestID := atomic.AddUint64(&requestCounter, 1)
	responseChan := make(chan string, 1)

	reqMutex.Lock()
	pendingRequests[requestID] = responseChan
	reqMutex.Unlock()

	// Send the message to the extension
	msgToExtension := ExtensionMessage{
		Type:      "SEND_CHAT_MESSAGE",
		RequestID: requestID,
		Message:   userMessage,
	}
	if err := activeExtension.WriteJSON(msgToExtension); err != nil {
		log.Println("Failed to send message to extension:", err)
		http.Error(w, `{"error": {"message": "Failed to communicate with extension."}}`, http.StatusInternalServerError)
		reqMutex.Lock()
		delete(pendingRequests, requestID)
		reqMutex.Unlock()
		return
	}
	log.Printf("Forwarded requestId %d to extension.", requestID)

	// Wait for the response or for the channel to be closed
	response, ok := <-responseChan
	if !ok {
		// Channel was closed, meaning the connection dropped
		http.Error(w, `{"error": {"message": "Extension disconnected during request."}}`, http.StatusInternalServerError)
		return
	}

	// Forward the extension's response to the client
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(response))
}

func main() {
	http.HandleFunc("/", handleWebSocket)
	http.HandleFunc("/v1/chat/completions", handleChatCompletions)

	port := "4437"
	log.Printf("Relay server starting on http://localhost:%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
