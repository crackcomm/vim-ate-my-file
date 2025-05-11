local o = vim.opt
local g = vim.g

g.mapleader = ","
g.maplocalleader = "\\"

o.backup = true
o.backupdir = vim.fn.expand("~/.cache/nvim/backup")

o.undodir = vim.fn.expand("~/.cache/nvim/undodir")
o.undofile = true

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
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1

-- vim-visual-multi
g.VM_silent_exit = 1
