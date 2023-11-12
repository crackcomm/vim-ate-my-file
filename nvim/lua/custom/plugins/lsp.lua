return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("crackcomm.lsp")
    end,
  },
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  { "j-hui/fidget.nvim", branch = "legacy" },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.1.1",
  },

  "jose-elias-alvarez/nvim-lsp-ts-utils",
  "folke/neodev.nvim",
  "simrat39/inlay-hints.nvim",
}
