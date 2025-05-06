local ts_utils = require("telescope.utils")

local M = {}

local root_cache = {}

function M.jj_root()
  local cwd = vim.fn.getcwd()
  if not root_cache[cwd] then
    local root, ret = ts_utils.get_os_command_output({ "jj", "root" })
    assert(ret == 0, "jj root not found")
    root_cache[cwd] = vim.uv.fs_realpath(root[1])
  end
  return root_cache[cwd]
end

function M.new_parent()
  vim.fn.system({ "jj", "new", "-B", "@", "--no-edit" })
end

function M.buf_rel_path(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.relpath(M.jj_root(), path) or path
end

return M
