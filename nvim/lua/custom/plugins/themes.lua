return {
  { "rainglow/vim" },
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    config = function()
      vim.cmd("colorscheme github_dark_default")
    end,
  },

  "aonemd/quietlight.vim",
}
