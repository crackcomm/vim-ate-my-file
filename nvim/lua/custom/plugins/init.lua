return {
  {
    "nvim-lua/plenary.nvim",
    dev = false,
    config = function()
      LOG_ = require("crackcomm.log")
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  { "sbdchd/neoformat" },
  "dyng/ctrlsf.vim",

  "mg979/vim-visual-multi",

  -- disables search highlighting when you are done searching and re-enables it when you search again
  "romainl/vim-cool",

  -- cs"'
  "tpope/vim-surround",

  -- quickfix window
  "romainl/vim-qf",

  {
    "kevinhwang91/nvim-ufo",
    -- event = { "User AstroFile", "InsertEnter" },
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      preview = {
        win_config = {
          border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
          winblend = 0,
          winhighlight = "Normal:LazyNormal",
        },
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
  },

  {
    dir = "~/x/llmlsp",
    config = function()
      require("colab").setup()
    end,
  },
}
