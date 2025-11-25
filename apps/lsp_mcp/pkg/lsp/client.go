package lsp

import (
	"context"
	"io"

	"encoding/json"
	"fmt"
	"log"
	"sync"

	"github.com/sourcegraph/go-lsp"
	"github.com/sourcegraph/jsonrpc2"
)

// MarkupContent is a struct that is not present in the forked go-lsp library.
type MarkupContent struct {
	Kind  string `json:"kind"`
	Value string `json:"value"`
}

// HoverReply is a struct that correctly models the response from gopls.
type HoverReply struct {
	Contents MarkupContent `json:"contents"`
}

// ServerCapabilities is a minimal local struct to handle variations in LSP server responses.
type ServerCapabilities struct {
	TextDocumentSync   lsp.TextDocumentSyncOptions `json:"textDocumentSync"`
	CompletionProvider lsp.CompletionOptions       `json:"completionProvider"`
	CodeActionProvider any                         `json:"codeActionProvider"`
}

// InitializeResult is a minimal local override to use our custom ServerCapabilities.
type InitializeResult struct {
	Capabilities ServerCapabilities `json:"capabilities"`
}

// ProgressParams is a local copy of lsp.ProgressParams with a flexible token type.
type ProgressParams[T any] struct {
	Token any `json:"token"` // string | int
	Value T   `json:"value"`
}

// Handler handles messages sent from the server and signals when ready.
type Handler struct {
	initReady       chan struct{}
	idle            chan struct{}
	mu              sync.Mutex
	tokens          map[string]struct{}
	initialLoadDone bool
	settings        any
}

// NewHandler creates a new handler for progress notifications.
func NewHandler(settings any) *Handler {
	h := &Handler{
		initReady: make(chan struct{}),
		idle:      make(chan struct{}),
		tokens:    make(map[string]struct{}),
		settings:  settings,
	}
	close(h.idle) // Start in an idle state.
	return h
}

// IsIdle returns true if there are no active work-in-progress tokens.
func (h *Handler) IsIdle() bool {
	h.mu.Lock()
	defer h.mu.Unlock()
	return len(h.tokens) == 0
}

// awaitInitialWorkspaceLoad blocks until the initial workspace load is complete.
func (h *Handler) awaitInitialWorkspaceLoad(ctx context.Context) error {
	select {
	case <-h.initReady:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

type ConfigurationItem struct {
	ScopeURI string `json:"scopeUri"`
	Section  string `json:"section"`
}

type ConfigurationParams struct {
	Items []ConfigurationItem `json:"items"`
}

// Handle handles incoming requests and notifications from the LSP server.
func (h *Handler) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
	log.Printf("jsonrpc2 handler received: %s", req.Method)

	switch req.Method {
	case "$/hello":
		// This is a non-standard notification that some servers send.
		// We can safely ignore it.
		return
	case "window/workDoneProgress/create":
		h.handleWorkDoneProgressCreate(req.ID, conn)
	case "$/progress":
		h.handleProgress(req.Params)
	case "workspace/configuration":
		h.handleWorkspaceConfiguration(ctx, conn, req)
	}
}

func (h *Handler) handleWorkspaceConfiguration(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
	var params ConfigurationParams
	if err := json.Unmarshal(*req.Params, &params); err != nil {
		log.Printf("could not unmarshal workspace/configuration params: %v", err)
		return
	}

	// Create a slice to hold the results, one for each item.
	results := make([]any, len(params.Items))
	settingsMap, ok := h.settings.(map[string]any)
	if !ok {
		// If settings are not a map, we can't look up sections. Reply with nils.
		log.Printf("handler.settings is not a map[string]any, cannot handle workspace/configuration")
		if err := conn.Reply(ctx, req.ID, results); err != nil {
			log.Printf("failed to reply to workspace/configuration: %v", err)
		}
		return
	}

	for i, item := range params.Items {
		if sectionSettings, sectionExists := settingsMap[item.Section]; sectionExists {
			results[i] = sectionSettings
		} else {
			results[i] = nil // Section not found in our settings.
		}
	}

	// Reply to the server with the settings.
	if err := conn.Reply(ctx, req.ID, results); err != nil {
		log.Printf("failed to reply to workspace/configuration: %v", err)
	}
}

// handleWorkDoneProgressCreate responds to the request to create a work done progress reporter.
func (h *Handler) handleWorkDoneProgressCreate(id jsonrpc2.ID, conn *jsonrpc2.Conn) {
	if err := conn.Reply(context.Background(), id, nil); err != nil {
		log.Printf("failed to reply to workDoneProgress/create: %v", err)
	}
}

// handleProgress parses and routes a $/progress notification.
func (h *Handler) handleProgress(params *json.RawMessage) {
	var p ProgressParams[any]
	if err := json.Unmarshal(*params, &p); err != nil {
		log.Printf("could not unmarshal progress params: %v", err)
		return
	}

	valueBytes, err := json.Marshal(p.Value)
	if err != nil {
		log.Printf("could not marshal progress value: %v", err)
		return
	}

	token := fmt.Sprintf("%v", p.Token)

	var begin lsp.WorkDoneProgressBegin
	if err := json.Unmarshal(valueBytes, &begin); err == nil && begin.Kind == "begin" {
		h.handleProgressBegin(token, &begin)
		return
	}

	var end lsp.WorkDoneProgressEnd
	if err := json.Unmarshal(valueBytes, &end); err == nil && end.Kind == "end" {
		h.handleProgressEnd(token)
	}
}

// handleProgressBegin handles the start of a progress notification.
func (h *Handler) handleProgressBegin(token string, begin *lsp.WorkDoneProgressBegin) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if len(h.tokens) == 0 {
		// Transitioning from idle to busy.
		h.idle = make(chan struct{})
	}
	h.tokens[token] = struct{}{}
	log.Printf("Progress begin: %s ('%s'). Total active: %d.", token, begin.Title, len(h.tokens))
}

// handleProgressEnd handles the end of a progress notification.
func (h *Handler) handleProgressEnd(token string) {
	h.mu.Lock()
	defer h.mu.Unlock()

	delete(h.tokens, token)
	log.Printf("Progress end: %s. Total active: %d.", token, len(h.tokens))

	if len(h.tokens) == 0 {
		// Transitioning from busy to idle.
		close(h.idle)
		// If this is the *first* time we've become idle, signal initial readiness.
		if !h.initialLoadDone {
			h.initialLoadDone = true
			close(h.initReady)
			log.Println("Server is ready (initial load complete).")
		}
	}
}

// Client is a generic Language Server Protocol client.
// It can be used to communicate with any LSP-compliant server.
type Client struct {
	conn    *jsonrpc2.Conn
	handler *Handler
}

// NewClient creates a new LSP client.
func NewClient(ctx context.Context, rwc io.ReadWriteCloser, handler *Handler) *Client {
	conn := jsonrpc2.NewConn(ctx, jsonrpc2.NewBufferedStream(rwc, jsonrpc2.VSCodeObjectCodec{}), handler)
	return &Client{
		conn:    conn,
		handler: handler,
	}
}

// awaitServerReady waits for the server to be fully initialized and idle.
func (c *Client) awaitServerReady(ctx context.Context) error {
	if err := c.handler.awaitInitialWorkspaceLoad(ctx); err != nil {
		return err
	}
	<-c.handler.idle
	return nil
}

// Initialize performs the full LSP initialization handshake.
func (c *Client) Initialize(ctx context.Context, params *lsp.InitializeParams) (*InitializeResult, error) {
	// Send the initialize request.
	var result InitializeResult
	if err := c.conn.Call(ctx, "initialize", params, &result); err != nil {
		return nil, err
	}

	// Send the initialized notification.
	if err := c.conn.Notify(ctx, "initialized", lsp.None{}); err != nil {
		return nil, fmt.Errorf("could not send initialized notification: %w", err)
	}

	return &result, nil
}

type DidChangeConfigurationParams struct {
	Settings any `json:"settings"`
}

// DidChangeConfiguration sends a `workspace/didChangeConfiguration` notification to the server.
func (c *Client) DidChangeConfiguration(ctx context.Context, params *DidChangeConfigurationParams) error {
	return c.conn.Notify(ctx, "workspace/didChangeConfiguration", params)
}

// Hover requests hover information at a given text document position.
func (c *Client) Hover(ctx context.Context, params *lsp.TextDocumentPositionParams) (string, error) {
	if err := c.awaitServerReady(ctx); err != nil {
		return "workspace loading", err
	}
	var result HoverReply
	err := c.conn.Call(ctx, "textDocument/hover", params, &result)
	if err != nil {
		return "", err
	}
	return result.Contents.Value, nil
}

func (c *Client) Definition(ctx context.Context, params *lsp.TextDocumentPositionParams) ([]lsp.Location, error) {
	if err := c.awaitServerReady(ctx); err != nil {
		return nil, err
	}
	var result []lsp.Location
	err := c.conn.Call(ctx, "textDocument/definition", params, &result)
	return result, err
}

func (c *Client) DidOpen(ctx context.Context, params *lsp.DidOpenTextDocumentParams) error {
	return c.conn.Notify(ctx, "textDocument/didOpen", params)
}

// Close closes the connection to the LSP server.
func (c *Client) Close() error {
	return c.conn.Close()
}
