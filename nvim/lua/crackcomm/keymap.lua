local function _str_to_desc(opts)
  if opts == nil then
    return {}
  end
  if type(opts) == "string" then
    return { desc = opts }
  end
  return opts
end

local M = {}

M.imap = function(tbl)
  vim.keymap.set("i", tbl[1], tbl[2], _str_to_desc(tbl[3]))
end

M.nmap = function(tbl)
  vim.keymap.set("n", tbl[1], tbl[2], _str_to_desc(tbl[3]))
end

M.vmap = function(tbl)
  vim.keymap.set("v", tbl[1], tbl[2], _str_to_desc(tbl[3]))
end

M.buf_nnoremap = function(tbl)
  tbl[3] = _str_to_desc(tbl[3])
  tbl[3].buffer = 0
  M.nmap(tbl)
end

M.buf_inoremap = function(tbl)
  tbl[3] = _str_to_desc(tbl[3])
  tbl[3].buffer = 0
  M.imap(tbl)
end

M.buf_vnoremap = function(tbl)
  tbl[3] = _str_to_desc(tbl[3])
  tbl[3].buffer = 0
  M.vmap(tbl)
end

return M
