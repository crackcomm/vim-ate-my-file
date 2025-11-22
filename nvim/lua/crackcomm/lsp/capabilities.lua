local M = {}

--- Checks if the LSP client supports formatting but not willSaveWaitUntil.
--- @param client vim.lsp.Client: LSP client
function M.supports_formatting(client)
  return (
    not client:supports_method("textDocument/willSaveWaitUntil")
    and client:supports_method("textDocument/formatting")
  )
end

--- Checks if any LSP client attached to the buffer supports the given method.
--- @param bufnr number: buffer number
--- @param method string: LSP method to check
function M.supports_method(bufnr, method)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end
  return false
end

--- Checks if any LSP client attached to the buffer supports document highlight.
--- @param bufnr number: buffer number
function M.supports_document_highlight(bufnr)
  return M.supports_method(bufnr, "textDocument/documentHighlight")
end

--- @return string|nil: action kind supported by the client
function M.supported_code_action(client, action_kind)
  if not client.supports_method("textDocument/codeAction") then
    return nil
  end
  local kinds = type(client.server_capabilities.codeActionProvider) == "table"
      and client.server_capabilities.codeActionProvider.codeActionKinds
      or {}
  for _, k in ipairs(kinds) do
    if k:sub(1, #action_kind) == action_kind then
      return k
    end
  end
  return nil
end

--- Finds supported code actions from a list.
--- @param client vim.lsp.Client: LSP client
--- @param actions string[]: list of action kinds to check
--- @return string[]: list of action kinds supported by the client
function M.supported_code_actions(client, actions)
  local supported = {}
  for _, action in ipairs(actions) do
    local kind = M.supported_code_action(client, action)
    if kind ~= nil then
      table.insert(supported, kind)
    end
  end
  return supported
end

return M
