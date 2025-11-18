package tooling

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/lsp"
	lsptypes "github.com/sourcegraph/go-lsp"
)

// Resolver defines the interface for language-specific symbol information retrieval.
type Resolver interface {
	GetInfo(ctx context.Context, symbol string) (string, error)
}

// GenericResolver provides a default implementation that uses hover.
type GenericResolver struct {
	Client     *lsp.Client
	LanguageID string
	RootURI    string
}

func NewGenericResolver(client *lsp.Client, langID, rootURI string) *GenericResolver {
	return &GenericResolver{Client: client, LanguageID: langID, RootURI: rootURI}
}

func (r *GenericResolver) GetInfo(ctx context.Context, symbol string) (string, error) {
	// For a generic resolver, the symbol itself is the most reasonable docContent.
	return GetHover(ctx, r.Client, r.LanguageID, symbol, symbol)
}

// LuaResolver provides a specialized implementation for Lua.
type LuaResolver struct {
	*GenericResolver
}

func NewLuaResolver(client *lsp.Client, rootURI string) *LuaResolver {
	return &LuaResolver{
		GenericResolver: NewGenericResolver(client, "lua", rootURI),
	}
}

// getDefinitionContentWithComments reads the content of a file from a given location
// and expands the range to include the full documentation comment block.
func getDefinitionContentWithComments(loc lsptypes.Location) (string, error) {
	filePath := strings.TrimPrefix(string(loc.URI), "file://")

	fileContent, err := os.ReadFile(filePath)
	if err != nil {
		return "", fmt.Errorf("could not read definition file '%s': %w", filePath, err)
	}

	lines := strings.Split(string(fileContent), "\n")
	definitionStartLine := loc.Range.Start.Line
	definitionEndLine := loc.Range.End.Line

	if definitionStartLine >= len(lines) || definitionEndLine >= len(lines) {
		return "", fmt.Errorf("invalid line range for definition in '%s'", filePath)
	}

	// Expand the range to include leading documentation comments (lines starting with '---').
	actualStartLine := definitionStartLine
	for i := definitionStartLine - 1; i >= 0; i-- {
		// Stop if the line is not a documentation comment or is empty.
		// A line that only contains whitespace is considered empty.
		trimmedLine := strings.TrimSpace(lines[i])
		if !strings.HasPrefix(trimmedLine, "---") && trimmedLine != "" {
			break
		}
		actualStartLine = i
	}

	// Expand the range to include trailing documentation comments.
	// Stop at the first line that does not start with '---'.
	actualEndLine := definitionEndLine
	for i := definitionEndLine + 1; i < len(lines); i++ {
		trimmedLine := strings.TrimSpace(lines[i])
		if !strings.HasPrefix(trimmedLine, "---") {
			break
		}
		actualEndLine = i
	}

	// Ensure that actualEndLine does not go beyond the bounds of the file.
	if actualEndLine >= len(lines) {
		actualEndLine = len(lines) - 1
	}

	return strings.Join(lines[actualStartLine:actualEndLine+1], "\n"), nil
}

// GetInfo for Lua gets both hover and definition information. If hover is not
// useful (e.g. "unknown"), it falls back to the definition. Otherwise, it
// combines them.
func (r *LuaResolver) GetInfo(ctx context.Context, symbol string) (string, error) {
	// For hover, a plain symbol is usually sufficient.
	hoverContent, hoverErr := GetHover(ctx, r.Client, r.LanguageID, symbol, symbol)

	// For definition of types, lua-ls may need more context.
	docContentForDefinition := fmt.Sprintf("--- @param _ %s", symbol)
	locations, defErr := GetDefinitionLocations(ctx, r.Client, r.LanguageID, symbol, docContentForDefinition)

	var definitionContent string
	if defErr == nil {
		// If locations are found, get the content with comments.
		content, err := getDefinitionContentWithComments(locations[0])
		if err != nil {
			// If reading the file fails, update defErr.
			defErr = err
		} else {
			definitionContent = content
		}
	}

	// If both failed, return a combined error.
	if hoverErr != nil && defErr != nil {
		return "", fmt.Errorf("both hover and definition failed.\nHover error: %v\nDefinition error: %v", hoverErr, defErr)
	}

	// If only hover failed, return the definition.
	if hoverErr != nil {
		return definitionContent, nil
	}

	// At this point, hover succeeded. Check if it's useful.
	isHoverUnhelpful := strings.Contains(hoverContent, ": unknown")

	// If hover is unhelpful, fallback to definition.
	if isHoverUnhelpful {
		if defErr == nil {
			// Definition is available, so use it.
			return definitionContent, nil
		} else {
			// Definition failed, so return the unhelpful hover content as a last resort.
			return hoverContent, nil
		}
	}

	// At this point, hover is helpful.

	// If definition is available, combine it with hover.
	if defErr == nil {
		var result strings.Builder
		result.WriteString(hoverContent)
		result.WriteString("\n\n---\n\n")
		result.WriteString(definitionContent)
		return result.String(), nil
	}

	// Otherwise, just return the hover content.
	return hoverContent, nil
}
