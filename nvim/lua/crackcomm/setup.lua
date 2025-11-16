local custom = require("crackcomm.telescope.custom")
local autocmd = require("crackcomm.common.autocmd")

local function register_vim_enter()
  -- Check if Neovim was started with a directory argument
  local args = vim.fn.argv()
  if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
    autocmd.window("VimEnter", function()
      vim.cmd("FrecencyValidate")
      custom.frecency()
    end)
  end
end

local function register_colorscheme()
  local overrides = require("crackcomm.common.colorscheme").overrides
  autocmd.window("ColorScheme", overrides)
end

local function register_filetypes()
  vim.filetype.add({
    extension = {
      fbs = "fbs",
      sky = "bzl",
      star = "bzl",
      atd = "ocaml",
      td = "tablegen",
      ts = "typescript",
      tsx = "typescriptreact",
    },
  })

  -- Set the comment string for the `fbs` filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fbs",
    callback = function()
      vim.bo.commentstring = "// %s"
    end,
  })
end

local function clear_default_keymaps()
  for _, bind in ipairs({
    -- default lsp keymaps
    "grn",
    "gra",
    "gri",
    "grr",
  }) do
    vim.keymap.del("n", bind)
  end
end

return function()
  --- @diagnostic disable-next-line: duplicate-set-field
  vim.deprecate = function() end
  require("crackcomm.format").setup()
  require("crackcomm.jj").setup()
  register_vim_enter()
  register_colorscheme()
  register_filetypes()
  clear_default_keymaps()
  require("crackcomm.telescope.mappings")
end
