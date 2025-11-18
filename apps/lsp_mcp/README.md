# LSP MCP Server

This server exposes Language Server Protocol (LSP) capabilities as a set of tools for an MCP-compatible agent. The primary goal is to provide a reliable way for an AI agent to query information about code symbols using actual LSP servers, ensuring the agent uses up-to-date and accurate information instead of relying on potentially outdated or hallucinated knowledge.

The server is configured via a JSON file (e.g., `config.json`) that specifies which language servers to manage.

## Architecture

This server manages LSP servers directly, communicating with them via JSON-RPC over stdio. It does **not** rely on a running Neovim instance.

LSP servers are launched on-demand when a tool requires their functionality. Once launched, an LSP server is kept alive to serve subsequent requests, avoiding the overhead of repeated startup. The server can manage multiple language servers, which are defined in its configuration file.

## Configuration

The server is configured by providing a JSON file (default: `config.json`) with a list of server configurations.

**Example `config.json`:**

```json
{
  "servers": [
    {
      "name": "lua-ls",
      "command": "lua-language-server",
      "languageId": "lua",
      "trace": true,
      "settings": {
        "Lua": {
          "workspace": {
            "library": ["/path/to/neovim/runtime/lua"]
          }
        }
      }
    }
  ]
}
```

## Tools

The server currently implements one primary tool.

### 1. `get_lsp_info`

Retrieves the signature and documentation for a given symbol using a configured LSP server.

For most languages, this is equivalent to a `textDocument/hover` request. For Lua (using `lua-ls`), it provides an enhanced result by combining hover information with the full definition and its preceding documentation comments.

**Input Schema:**

```json
{
  "type": "object",
  "properties": {
    "symbol": {
      "type": "string",
      "description": "The fully qualified name of the symbol to query (e.g., `vim.lsp.buf.format`)."
    },
    "lsp_server": {
      "type": "string",
      "description": "The name of the configured LSP server to use (e.g., `lua-ls`)."
    },
    "root_uri": {
      "type": "string",
      "description": "Optional. The root URI of the workspace (e.g., `file:///path/to/project`)."
    }
  },
  "required": ["symbol", "lsp_server"]
}
```

**Output Schema:**

```json
{
  "type": "object",
  "properties": {
    "documentation": {
      "type": "string",
      "description": "The signature and help text for the symbol."
    }
  }
}
```

**Example:**

- **Request:**

  ```json
  {
    "tool_name": "get_lsp_info",
    "parameters": {
      "symbol": "vim.lsp.buf.format",
      "lsp_server": "lua-ls",
      "root_uri": "file:///path/to/neovim/runtime"
    }
  }
  ```

- **Result (for Lua):**
  ```json
  {
    "tool_result": {
      "documentation": "(global) vim.lsp.buf.format: function|unknown\n───────────────────────────────────────────────────────────────────────\n Formats a buffer using the attached (and optionally filtered) language\n server clients.\n\n---\n\n--- Formats a buffer using the attached (and optionally filtered) language\n--- clients.\n--- @param opts? vim.lsp.buf.format.Opts\nfunction M.format(opts) end"
    }
  }
  ```
