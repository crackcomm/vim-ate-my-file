local custom = require("crackcomm.telescope.custom")
local autocmd = require("crackcomm.autocmd")

local function vim_enter()
  -- Check if Neovim was started with a directory argument
  local args = vim.fn.argv()
  if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
    autocmd.autocmd_global("VimEnter", function()
      vim.cmd("FrecencyValidate")
      custom.frecency()
    end)
  end
end

return function()
  --- @diagnostic disable-next-line: duplicate-set-field
  vim.deprecate = function() end
  require("crackcomm.filetypes")
  require("crackcomm.jj").setup()
  vim_enter()
end
