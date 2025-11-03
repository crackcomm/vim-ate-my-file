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
      -- "next" on Ctrl+Alt+A
      vim.keymap.set("n", string.char(0x1b, 0x01), function()
        harpoon:list():next()
      end, { desc = "Harpoon Next (raw Ctrl+Alt+A)" })

      -- "prev" on Ctrl+Alt+D
      vim.keymap.set("n", string.char(0x1b, 0x04), function()
        harpoon:list():prev()
      end, { desc = "Harpoon Prev (raw Ctrl+Alt+D)" })

      require("telescope").load_extension("harpoon")
    end,
  },
}
