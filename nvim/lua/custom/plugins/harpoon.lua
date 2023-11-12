return {
  {
    -- Faster file navigation
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 10,
        },
        global_settings = {
          tabline = true,
        },
      })

      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
      vim.keymap.set("n", "<leader>hu", ui.toggle_quick_menu, { desc = "[H]arpoon [U]I" })
      vim.keymap.set("n", "<leader>gm", "<cmd>Telescope harpoon marks<CR>", { desc = "[H]arpoon [M]arks" })
      for id = 1, 5 do
        vim.keymap.set("n", "<leader>h" .. id, function()
          ui.nav_file(id)
        end, { desc = "[H]arpoon File [" .. id .. "]" })
      end

      require("telescope").load_extension("harpoon")
    end,
  },
}
