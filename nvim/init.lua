--[[
	init.lua
--]]

require("crackcomm.common.globals")
require("crackcomm.options")

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

require("crackcomm.setup")()
