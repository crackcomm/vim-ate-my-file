package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"

	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/manager"
)

// configFile is the path to the configuration file for the LSP manager.
var configFile = flag.String("config", "config.json", "path to the configuration file")

var lspManager *manager.Manager

func main() {
	flag.Parse() // Parse command-line flags

	// Create a new LSP manager.
	var err error
	lspManager, err = manager.NewManager(*configFile)
	if err != nil {
		log.Fatalf("could not create new manager: %v", err)
	}

	// Set up the MCP server.
	s := server.NewMCPServer(
		"LSP",
		"1.0.0",
		server.WithToolCapabilities(false),
	)

	// Add the get_lsp_info tool.
	tool := mcp.NewTool("get_lsp_info",
		mcp.WithDescription("Retrieves the signature and documentation for a given Neovim LSP symbol."),
		mcp.WithString("symbol",
			mcp.Required(),
			mcp.Description("The fully qualified name of the Lua symbol (e.g., `vim.lsp.buf.format`)."),
		),
		mcp.WithString("lsp_server",
			mcp.Required(),
			mcp.Description("The name of the LSP server to use (e.g., `lua-ls`)."),
		),
		mcp.WithString("root_uri",
			mcp.Description("The root URI of the workspace (e.g., `file:///path/to/project`). Defaults to empty string if not provided."),
		),
	)
	s.AddTool(tool, getLSPInfoHandler)

	// Start the server.
	if err := server.ServeStdio(s); err != nil {
		fmt.Printf("Server error: %v\n", err)
	}
}

// getLSPInfoHandler is an adapter that connects the MCP server to the tool's implementation.
func getLSPInfoHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	// Extract parameters from the MCP request.
	symbol, err := request.RequireString("symbol")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}
	lspServer, err := request.RequireString("lsp_server")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}
	rootURI := request.GetString("root_uri", "")

	// Get a resolver for the specified server and workspace.
	resolver, err := lspManager.GetResolver(lspServer, rootURI)
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("failed to get resolver: %v", err)), nil
	}

	// Call the actual implementation.
	info, err := resolver.GetInfo(ctx, symbol)
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("tool implementation failed: %v", err)), nil
	}

	// Format the result as an MCP response.
	return mcp.NewToolResultText(info), nil
}
