return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    config = function()
      require("crackcomm.treesitter.setup")
    end,
  },
  -- "nvim-treesitter/nvim-treesitter-context",
  -- "JoosepAlviste/nvim-ts-context-commentstring", -- broken, unused
}
