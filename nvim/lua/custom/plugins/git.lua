return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          vim.keymap.set("n", "<leader>gD", function()
            vim.cmd("wincmd w") -- switch to the diff window
            vim.cmd("q") -- close it
          end, { buffer = bufnr, desc = "[G]it [D]iff close" })
        end,
      })

      vim.keymap.set("n", "<leader>gs", ":Gitsigns preview_hunk_inline<CR>", { desc = "[G]it preview hunk inline" })
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end)

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end)

      vim.keymap.set("n", "<leader>gd", function()
        gs.diffthis()
      end, { desc = "[G]it [D]iff" })

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
