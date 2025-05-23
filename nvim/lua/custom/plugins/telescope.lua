return {
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("crackcomm.telescope.setup")
    end,
  },
  "nvim-telescope/telescope-dap.nvim",
  "nvim-telescope/telescope-ui-select.nvim",
  "nvim-telescope/telescope-file-browser.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require("neoclip").setup()
    end,
  },
  "zschreur/telescope-jj.nvim",
  "nvim-telescope/telescope-frecency.nvim",
}
