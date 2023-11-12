return {
  "mfussenegger/nvim-dap",
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("crackcomm.dap").setup()
      require("crackcomm.dap").setupui()
    end,
  },
  "mfussenegger/nvim-dap-python",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
  },
  "theHamsta/nvim-dap-virtual-text",
}
