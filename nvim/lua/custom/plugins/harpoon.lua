return {
  {
    -- Faster file navigation
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
      end, { desc = "[H]arpoon [A]dd file" })

      vim.keymap.set("n", "<leader>hu", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "[H]arpoon [U]I" })

      vim.keymap.set("n", "<leader>gm", "<cmd>Telescope harpoon marks<CR>", { desc = "[H]arpoon [M]arks" })

      for id = 1, 5 do
        vim.keymap.set("n", "<leader>h" .. id, function()
          harpoon:list():select(id)
        end, { desc = "[H]arpoon File [" .. id .. "]" })
      end

      -- kitty +kitten show_key
      -- "next" on Ctrl+>
      vim.keymap.set("n", "<space>.", function()
        harpoon:list():next()
      end, { silent = true, desc = "Harpoon Next (raw Ctrl+Alt+A)" })

      -- "prev" on Ctrl+<
      vim.keymap.set("n", "<space>,", function()
        harpoon:list():prev()
      end, { silent = true, desc = "Harpoon Prev (raw Ctrl+Alt+D)" })

      require("telescope").load_extension("harpoon")
    end,
  },
}
