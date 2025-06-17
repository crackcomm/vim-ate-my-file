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
    event = {},
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
    config = function()
      local ufo = require("ufo")

      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = false

      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zZ", ufo.peekFoldedLinesUnderCursor, { desc = "Peek folded lines under cursor" })

      ufo.setup()
    end,
  },

  {
    "chrisgrieser/nvim-origami",
    dependencies = { "kevinhwang91/nvim-ufo" },
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("origami").setup({
        -- requires with `nvim-ufo`
        keepFoldsAcrossSessions = false, -- package.loaded["ufo"] ~= nil,
        useLspFoldsWithTreesitterFallback = false,

        pauseFoldsOnSearch = true,

        -- incompatible with `nvim-ufo`
        foldtextWithLineCount = {
          enabled = package.loaded["ufo"] == nil,
          template = "   %s lines", -- `%s` gets the number of folded lines
          hlgroupForCount = "Comment",
        },

        foldKeymaps = {
          setup = true, -- modifies `h` and `l`
          hOnlyOpensOnFirstColumn = false,
        },

        -- redundant with `nvim-ufo`
        autoFold = {
          enabled = false,
          kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
        },
      })
    end,
  },

  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {
      keys = "qweasdzcpoiukjmnb",
    },
    config = function(_, opts)
      local hop = require("hop")
      hop.setup(opts)
      -- local directions = require("hop.hint").HintDirection
      vim.keymap.set("n", "<C-p>", function()
        --- @diagnostic disable: missing-fields
        hop.hint_words({})
        -- hop.hint_char1({})
      end, { remap = true, desc = "Hop to char" })
    end,
  },

  {
    "echasnovski/mini.jump",
    version = false,
    config = function()
      require("mini.jump").setup()
    end,
  },
}
