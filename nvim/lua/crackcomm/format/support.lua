local M = {}

local lsp_format_enabled_clients = {
  "gopls",
}

local lsp_code_actions_enabled_clients = {
  "gopls",
  "ts_ls",
}

local ignored_filetypes = {
  "gitcommit",
  "json",
  "jsonc",
  "markdown",
  "txt",
}

function M.filetype_format_ignored(bufnr)
  local ft = vim.b[bufnr].filetype
  for _, ignored_ft in ipairs(ignored_filetypes) do
    if ft == ignored_ft then
      return true
    end
  end
  return false
end

--- Checks if any LSP client attached to the buffer supports formatting.
--- Does not consider whether formatting is enabled for that client.
---
--- @param bufnr number: buffer number
--- @return vim.lsp.Client|nil: LSP client that supports formatting, or nil if none found
function M.buf_lsp_formatting_client(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
      return client
    end
  end
  return nil
end

function M.lsp_format_enabled(client)
  return vim.tbl_contains(lsp_format_enabled_clients, client.name)
end

function M.lsp_code_actions_enabled(client)
  return vim.tbl_contains(lsp_code_actions_enabled_clients, client.name)
end

return M
