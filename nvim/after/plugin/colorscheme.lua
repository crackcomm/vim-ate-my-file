-- Enable true color support
vim.opt.termguicolors = true

-- Set the background to dark
vim.opt.background = "dark"

vim.cmd([[
  highlight TabLine guibg=NONE gui=NONE
  highlight clear SignColumn

  highlight Error guibg=#470404
  highlight Conceal guibg=#1a1a1a
]])
