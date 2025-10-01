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
    config = function()
      local ls = require("luasnip")
      ls.add_snippets("sh", {
        ls.parser.parse_snippet("bash", "#!/usr/bin/env bash\n$0"),
      })
    end,
  },

  "jose-elias-alvarez/nvim-lsp-ts-utils",
  "folke/neodev.nvim",

  {
    "smjonas/inc-rename.nvim",
    dependencies = { "stevearc/dressing.nvim" },
    config = function()
      require("inc_rename").setup({
        input_buffer_type = "dressing",
      })
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
      vim.api.nvim_del_augroup_by_name("lsp_signature")
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
