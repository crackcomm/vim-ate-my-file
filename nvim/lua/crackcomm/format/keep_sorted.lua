local bufutil = require("crackcomm.common.bufutil")

--- This module provides a function to sort the current buffer using the external
--- "keep-sorted" tool if the buffer contains a special marker.
---
--- @param bufnr number The buffer number to process.
return function(bufnr)
  local has_keep_sorted = false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match("^%s*# keep%-sorted") then
      has_keep_sorted = true
      break
    end
  end

  if has_keep_sorted then
    bufutil.file_action(bufnr, function(filepath)
      vim.fn.system({ "keep-sorted", filepath })
    end)
  end
end
