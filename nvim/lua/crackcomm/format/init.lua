local bufutil = require("crackcomm.common.bufutil")
local support = require("crackcomm.format.support")
local keep_sorted = require("crackcomm.format.keep_sorted")
local lsp_code_actions = require("crackcomm.format.lsp_code_actions")

local M = {}

function M.setup()
  local function on_format_complete(bufnr)
    bufutil.write(bufnr)
    keep_sorted(bufnr)
    vim.schedule(function()
      vim.b[bufnr].is_saving = nil
    end)
  end

  vim.keymap.set("n", "ss", function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Guard against concurrent changes.
    if not vim.b[bufnr] or vim.b[bufnr].is_saving then
      return
    end

    -- If the buffer is not modifiable, skip formatting.
    -- This can happen for read-only files or special buffers.
    if vim.b[bufnr].modifiable == false then
      return
    end

    -- Skip formatting for ignored filetypes.
    if support.filetype_format_ignored(bufnr) then
      bufutil.write(bufnr)
      return
    end

    -- Guard against concurrent changes.
    vim.b[bufnr].is_saving = true

    -- Find an LSP client that **supports** formatting for this buffer.
    -- This LSP will also be used for code actions if enabled.
    -- It will only be used to format if it is explicitly enabled.
    local client = support.buf_lsp_formatting_client(bufnr)

    -- Pick a formatting method.
    local format = function()
      if client ~= nil and support.lsp_format_enabled(client) then
        pcall(vim.lsp.buf.format, { bufnr = bufnr, timeout_ms = 750 })
      else
        vim.cmd("Neoformat")
      end
      on_format_complete(bufnr)
    end

    -- If LSP formatting is enabled for this buffer, use it.
    if client then
      -- If LSP code actions are enabled for this buffer, run them first.
      if support.lsp_code_actions_enabled(client) then
        lsp_code_actions.apply_code_actions(client, bufnr, format)
        return
      end
    end

    -- If code actions are not enabled for this client, only format.
    format()
  end, { noremap = false, silent = true })
end

return M
