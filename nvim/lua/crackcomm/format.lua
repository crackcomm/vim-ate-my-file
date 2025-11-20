local capabilities = require("crackcomm.lsp.capabilities")

local M = {}

local function is_ignored_filetype()
  local ignored_filetypes = {
    "gitcommit",
    "json",
    "jsonc",
    "markdown",
    "txt",
  }
  local ft = vim.bo.filetype
  for _, ignored_ft in ipairs(ignored_filetypes) do
    if ft == ignored_ft then
      return true
    end
  end
  return false
end

function M.setup()
  vim.keymap.set("n", "ss", function()
    -- if LSP supports formatting → just `:w`
    if not is_ignored_filetype() and capabilities.lsp_supports_formatting() then
      vim.cmd("write")
      return
    end

    vim.cmd("Neoformat")
    vim.cmd("write")

    local has_keep_sorted = false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match("^%s*# keep%-sorted") then
        has_keep_sorted = true
        break
      end
    end

    if has_keep_sorted then
      local filepath = vim.fn.expand("%:p")
      local view = vim.fn.winsaveview()
      vim.fn.system({ "keep-sorted", filepath })
      vim.cmd("checktime") -- reload only if file changed
      vim.fn.winrestview(view)
    end
  end, { noremap = true, silent = true })
end

return M
