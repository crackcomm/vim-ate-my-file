return {
  {
    -- "sourcegraph/sg.nvim",
    dir = "~/ocxmr-repos/plugins/sg.nvim",
    -- dependencies = {
    --   "nvim-lua/plenary.nvim",
    --   "nvim-telescope/telescope.nvim",
    -- },
    config = function()
      require("sg").setup({
        enable_cody = true,
        get_nvim_agent = function()
          return "/home/pah/ocxmr-repos/plugins/sg.nvim/target/debug/sg-nvim-agent"
        end,
      })
    end,
  },
}
