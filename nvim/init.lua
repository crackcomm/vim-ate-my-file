--[[
	init.lua
--]]

require("crackcomm.globals")

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

vim.opt.backup = true
vim.opt.backupdir = vim.fn.expand("~/.cache/nvim/backup")

vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undodir")
vim.opt.undofile = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- local pluginspath = vim.fn.stdpath("config") .. "/plugin"
require("lazy").setup("custom.plugins", {
  dev = {
    -- directory where you store your local plugin projects
    -- path = pluginspath,
    path = "~/ocxmr-repos/plugins",
    fallback = false,
  },
})

require("crackcomm.filetypes")
