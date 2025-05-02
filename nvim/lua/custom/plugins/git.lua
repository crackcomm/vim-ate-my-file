return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
      })

      local overrides = require("crackcomm.themes").overrides

      overrides()

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          overrides()
        end,
      })
    end,
  },
  -- "rhysd/git-messenger.vim",
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup({
        format_fn = require("blame.formats.default_formats").date_message,
      })
    end,
  },
}
