local M = {}

function M.overrides()
  vim.cmd([[
      highlight clear SignColumn
      highlight TabLine guibg=NONE gui=NONE
      highlight GitSignsAdd ctermfg=2 guifg=#a7da1e
      highlight GitSignsChange ctermfg=3 guifg=#f7b83d
      highlight GitSignsDelete ctermfg=1 guifg=#e61f44
      highlight GitSignsChangedelete ctermfg=4 guifg=#e61f44
  ]])
end

return M
