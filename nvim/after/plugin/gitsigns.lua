local overrides = require("crackcomm.themes").overrides

overrides()

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    overrides()
  end,
})
