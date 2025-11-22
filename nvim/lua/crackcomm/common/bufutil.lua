local M = {}

--- Write the buffer to disk.
---
--- @param bufnr number: buffer number
function M.write(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.write()
  end)
end

--- Perform a file action on the buffer's file path.
--- The view is preserved and the buffer is reloaded after the action.
---
--- @param bufnr number: buffer number
--- @param fn function: function that takes the file path as argument
function M.file_action(bufnr, fn)
    -- resolve buffer path (empty string if none)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return
  end

  local view = vim.fn.winsaveview()
  fn(filepath)
  vim.cmd.checktime(filepath)
  vim.fn.winrestview(view)
end

return M
