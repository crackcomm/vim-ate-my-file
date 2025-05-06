--- LSP Handlers overrides
local lsp_telescope = require("crackcomm.lsp.telescope")

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
    signs = {
      severity = { min = vim.diagnostic.severity.ERROR },
    },
    underline = {
      severity = { min = vim.diagnostic.severity.WARN },
    },
    virtual_text = true,
  })

vim.lsp.handlers["window/showMessage"] = require("crackcomm.lsp.show_message")

local M = {}

M.definition = function()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results_per_client, _, ctx)
    -- if exactly one location, jump there:
    local total = 0
    for _, r in pairs(results_per_client) do
      if r.result and not vim.tbl_isempty(r.result) then
        total = total + 1
      end
    end
    if total == 1 then
      for cid, r in pairs(results_per_client) do
        local loc = (type(r.result) == "table" and r.result[1] or r.result)
        vim.lsp.util.jump_to_location(loc, vim.lsp.get_client_by_id(cid).offset_encoding)
        return
      end
    end
    if total == 0 then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    -- otherwise show our picker
    lsp_telescope.pick("LSP Definitions", results_per_client, { context = ctx })
  end)
end

M.implementation = function()
  local params = vim.lsp.util.make_position_params(0, "utf-8")

  vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
    local bufnr = ctx.bufnr
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- In go code, I do not like to see any mocks for impls
    if ft == "go" then
      local new_result = vim.tbl_filter(function(v)
        return not string.find(v.uri, "mock_")
      end, result)

      if #new_result > 0 then
        result = new_result
      end
    end

    vim.lsp.handlers["textDocument/implementation"](err, result, ctx, config)
    vim.cmd([[normal! zz]])
  end)
end

return M
