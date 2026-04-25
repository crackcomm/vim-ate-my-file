local M = {}

local lspd = { "lspd", "-log-file", "/tmp/lspd.log", "--" }

--- Wraps an LSP command with 'lspd'.
---
--- @param cmd table The command table, e.g., {'gopls'}.
--- @return table The wrapped command, e.g., {'lspd', 'gopls'}.
function M.wrap_cmd(cmd)
  if vim.fn.executable("lspd") ~= 1 then
    return cmd
  end

  if not cmd or type(cmd) ~= "table" then
    return cmd
  end

  local new_cmd = cmd
  if new_cmd[1] ~= "lspd" then
    new_cmd = vim.tbl_flatten({ lspd, cmd })
  end
  return new_cmd
end

--- Starts an LSP RPC client with a wrapped command.
--- This is a helper for cmd functions that return a client.
---
--- @param cmd table The command to start.
--- @param dispatchers table The dispatchers table.
--- @param options table|nil Options for vim.lsp.rpc.start.
function M.start_wrapped_rpc(cmd, dispatchers, options)
  return vim.lsp.rpc.start(M.wrap_cmd(cmd), dispatchers, options)
end

return M
