local M = {}

function M.supports_formatting(client)
  return (
    not client:supports_method("textDocument/willSaveWaitUntil")
    and client:supports_method("textDocument/formatting")
  )
end

function M.supports_document_highlight(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/documentHighlight", bufnr) then
      return true
    end
  end
  return false
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

function M.lsp_supports_formatting()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
      return true
    end
  end
  return false
end

return M
