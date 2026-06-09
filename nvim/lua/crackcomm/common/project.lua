-- Utility functions for project-related tasks.
local M = {}

local plenary_path = require("plenary.path")

local cache = {}

---Finds the root directory of the project for a given buffer.
---The root is determined by the presence of a `.git` or `.jj` directory.
---@param bufnr number|nil The buffer number to check. Defaults to the current buffer.
---@return string|nil The path to the project root, or nil if not found.
function M.find_root(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path_str = vim.api.nvim_buf_get_name(bufnr)
  if path_str == "" then
    path_str = vim.fn.getcwd()
  end

  local start_dir = plenary_path:new(path_str):parent()
  if not start_dir then
    return nil
  end
  local start_dir_str = tostring(start_dir)

  if cache[start_dir_str] then
    return cache[start_dir_str]
  end

  local root_marker = vim.fn.finddir(".git,.jj", start_dir_str .. ";")

  if root_marker == "" then
    cache[start_dir_str] = nil
    return nil
  end

  local root = plenary_path:new(root_marker):parent()
  local root_str = tostring(root)
  cache[start_dir_str] = root_str
  return root_str
end

return M
