return {
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({})
    end,
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
