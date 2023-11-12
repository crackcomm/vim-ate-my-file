local o = vim.opt

o.belloff = "all"
o.compatible = false
-- o.cmdheight = 1

o.updatetime = 200

-- Set tabstop, shiftwidth, and softtabstop to 2
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2

-- Expand tabs to spaces
o.expandtab = true

-- Enable relative line numbers
o.signcolumn = "yes"
o.relativenumber = true

-- Disable ruler and show columns on Ctrl+G
o.ruler = false

-- Set custom statusline with coc.nvim integration
-- o.statusline = [[%!luaeval('coc#status()') .. get(b:, 'coc_current_function', '')]]

-- disable builtin file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
