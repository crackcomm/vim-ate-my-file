package tooling

import (
	"context"
	"fmt"

	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/lsp"
	lsptypes "github.com/sourcegraph/go-lsp"
)

// GetHover retrieves hover information for a given symbol from a specified LSP client.
// This function is generic and should NOT contain language-specific logic for `docContent` creation.
// Language-specific heuristics for `docContent` should be handled by the respective Resolvers.
func GetHover(ctx context.Context, client *lsp.Client, langID, symbol, docContent string) (string, error) {
	docURI := lsptypes.DocumentURI(fmt.Sprintf("file:///virtual-%s", symbol))

	err := client.DidOpen(ctx, &lsptypes.DidOpenTextDocumentParams{
		TextDocument: lsptypes.TextDocumentItem{
			URI:        docURI,
			LanguageID: langID,
			Version:    1,
			Text:       docContent,
		},
	})
	if err != nil {
		return "", fmt.Errorf("didOpen failed: %w", err)
	}

	hoverContent, err := client.Hover(ctx, &lsptypes.TextDocumentPositionParams{
		TextDocument: lsptypes.TextDocumentIdentifier{URI: docURI},
		Position:     lsptypes.Position{Line: 0, Character: len(docContent)},
	})
	if err != nil {
		return "", fmt.Errorf("hover request failed: %w", err)
	}

	return hoverContent, nil
}

// GetDefinitionLocations retrieves the definition locations for a given symbol.
// This function is a generic wrapper around the `textDocument/definition` LSP call.
func GetDefinitionLocations(ctx context.Context, client *lsp.Client, langID, symbol, docContent string) ([]lsptypes.Location, error) {
	docURI := lsptypes.DocumentURI(fmt.Sprintf("file:///virtual-%s", symbol))

	err := client.DidOpen(ctx, &lsptypes.DidOpenTextDocumentParams{
		TextDocument: lsptypes.TextDocumentItem{
			URI:        docURI,
			LanguageID: langID,
			Version:    1,
			Text:       docContent,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("didOpen failed: %w", err)
	}

	locations, err := client.Definition(ctx, &lsptypes.TextDocumentPositionParams{
		TextDocument: lsptypes.TextDocumentIdentifier{URI: docURI},
		// Position the cursor at the end of the symbol within the docContent.
		Position: lsptypes.Position{Line: 0, Character: len(docContent)},
	})
	if err != nil {
		return nil, fmt.Errorf("definition request failed: %w", err)
	}

	if len(locations) == 0 {
		return nil, fmt.Errorf("no definition found for symbol '%s'", symbol)
	}

	return locations, nil
}
