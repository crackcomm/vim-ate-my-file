package tooling_test

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/manager"
)

// TestResolver_GetInfo tests the GetInfo function of the resolver.
func TestResolver_GetInfo(t *testing.T) {
	// Use a relevant directory as the workspace root.
	cwd, err := os.Getwd()
	if err != nil {
		t.Fatalf("could not get current working directory: %v", err)
	}
	rootURI := "file://" + filepath.Join(cwd, "..", "..", "..", "..", "nvim")
	t.Logf("Using workspace root URI: %s", rootURI)

	// Create a new manager.
	manager, err := manager.NewManager("../../config.json")
	if err != nil {
		t.Fatalf("could not create new manager: %v", err)
	}

	// Get the lua-ls resolver.
	resolver, err := manager.GetResolver("lua-ls", rootURI)
	if err != nil {
		t.Fatalf("could not get lua-ls resolver: %v", err)
	}
	client, err := manager.GetClient("lua-ls", rootURI)
	if err != nil {
		t.Fatalf("could not get lua-ls client: %v", err)
	}
	defer client.Close()

	// Wait for the server to finish its initial analysis.
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	{
		// For this symbol, hover is sufficient, so we expect the hover content.
		symbol := "vim.lsp.buf.format"
		info, err := resolver.GetInfo(ctx, symbol)
		if err != nil {
			t.Fatalf("GetInfo failed for '%s': %v", symbol, err)
		}

		// Check that we received the hover content.
		expectedContent := "function M.format(opts?: vim.lsp.buf.format.Opts)"
		if !strings.Contains(info, expectedContent) {
			t.Errorf("expected info for '%s' to contain %q, but got:\n%s", symbol, expectedContent, info)
		}

		t.Logf("Received info for '%s':\n%s", symbol, info)
	}

	{
		// For this symbol, hover returns "unknown", so we expect the resolver to
		// fall back to GetDefinition.
		symbol := "vim.lsp.buf.format.Opts"
		info, err := resolver.GetInfo(ctx, symbol)
		if err != nil {
			t.Fatalf("GetInfo failed for '%s': %v", symbol, err)
		}

		// Check that we received the definition content.
		expectedContent := "--- @class vim.lsp.buf.format.Opts"
		if !strings.Contains(info, expectedContent) {
			t.Errorf("expected info for '%s' to contain %q, but got:\n%s", symbol, expectedContent, info)
		}

		t.Logf("Received info for '%s':\n%s", symbol, info)
	}
}
