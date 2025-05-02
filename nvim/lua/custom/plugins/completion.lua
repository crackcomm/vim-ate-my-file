return {
  -- TODO: set back to origin when #2165 is merged
  {
    "crackcomm/nvim-cmp",
    config = function()
      require("crackcomm.completion")
    end,
  },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-nvim-lua" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "onsails/lspkind-nvim" },
  { "tamago324/cmp-zsh" },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
