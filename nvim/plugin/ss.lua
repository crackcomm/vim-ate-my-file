vim.keymap.set("n", "ss", function()
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
