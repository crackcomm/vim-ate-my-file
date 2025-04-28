return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "ofirgall/inlay-hints.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("crackcomm.lsp")
    end,
  },

  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        notification = {
          window = {
            align = "bottom",
            relative = "editor",
          },
        },
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.1.1",
  },

  "jose-elias-alvarez/nvim-lsp-ts-utils",
  "folke/neodev.nvim",

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()

      vim.keymap.set("n", "<leader>rn", ":IncRename ")
    end,
  },

  {
    "stevanmilic/nvim-lspimport",
    config = function()
      -- vim.keymap.set("n", "<leader>a", require("lspimport").import, { noremap = true })
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup()
    end,
  },
}
