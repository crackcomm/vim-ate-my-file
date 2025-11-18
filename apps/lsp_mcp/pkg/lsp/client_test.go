package lsp

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/sourcegraph/go-lsp"
)

func TestClient_Gopls(t *testing.T) {
	ctx := context.Background()

	// Get absolute path to the package directory.
	absPath, err := filepath.Abs(".")
	if err != nil {
		t.Fatalf("failed to get absolute path: %v", err)
	}

	// Configure gopls server.
	gopls := &ServerConfig{
		Command: "gopls",
		Args:    []string{"-rpc.trace"},
		WorkDir: absPath,
	}

	// Start the server.
	rwc, err := gopls.Start()
	if err != nil {
		t.Fatalf("failed to start gopls: %v", err)
	}
	defer rwc.Close()

	// Create a new client.
	handler := NewHandler(nil)
	client := NewClient(ctx, rwc, handler)
	defer client.Close()

	// Send initialize request.
	_, err = client.Initialize(ctx, &lsp.InitializeParams{
		RootURI: lsp.DocumentURI("file://" + absPath),
		Capabilities: lsp.ClientCapabilities{
			Window: lsp.WindowClientCapabilities{
				WorkDoneProgress: true,
			},
		},
	})
	if err != nil {
		t.Fatalf("initialize failed: %v", err)
	}

	// Open the client.go file and send a didOpen notification.
	clientGoPath := filepath.Join(absPath, "client.go")
	clientGoURI := lsp.DocumentURI("file://" + clientGoPath)
	content, err := os.ReadFile(clientGoPath)
	if err != nil {
		t.Fatalf("failed to read client.go: %v", err)
	}
	err = client.DidOpen(ctx, &lsp.DidOpenTextDocumentParams{
		TextDocument: lsp.TextDocumentItem{
			URI:        clientGoURI,
			LanguageID: "go",
			Version:    1,
			Text:       string(content),
		},
	})
	if err != nil {
		t.Fatalf("didOpen notification failed: %v", err)
	}

	// Wait for the server to be ready.
	t.Log("Waiting for server to be ready...")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := client.awaitServerReady(ctx); err != nil {
		t.Fatalf("timed out waiting for LSP server to be ready: %v", err)
	}
	t.Log("Server is ready.")

	// Perform a hover request on the 'Initialize' function in client.go.
	hoverContent, err := client.Hover(ctx, &lsp.TextDocumentPositionParams{
		TextDocument: lsp.TextDocumentIdentifier{
			URI: clientGoURI,
		},
		Position: lsp.Position{
			Line:      211, // Line of the Initialize function
			Character: 9,   // Character position within the function name
		},
	})
	if err != nil {
		t.Fatalf("hover request failed: %v", err)
	}

	if hoverContent == "" {
		t.Fatal("expected hover contents, got empty string")
	}

	t.Logf("Hover contents: %s", hoverContent)
}
