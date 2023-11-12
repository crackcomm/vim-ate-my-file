require("telescope").setup({
  pickers = {
    colorscheme = {
      enable_preview = true,
    },

    find_files = {
      -- I don't like having the cwd prefix in my files
      find_command = vim.fn.executable("fdfind") == 1 and { "fdfind", "--strip-cwd-prefix", "--type", "f" } or nil,

      mappings = {
        n = {
          ["kj"] = "close",
        },
      },
    },

    git_branches = {
      mappings = {
        i = {
          ["<C-a>"] = false,
        },
      },
    },

    buffers = {
      sort_lastused = true,
      sort_mru = true,
    },
  },

  extensions = {
    fzf_writer = {
      use_highlighter = false,
      minimum_grep_characters = 6,
    },

    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- even more opts
      }),
    },

    file_browser = {
      -- theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      -- hijack_netrw = true,
      select_buffer = true,
      respect_gitignore = true,
      display_stat = { "size" },
    },
  },

  defaults = {
    winblend = 0,
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.95,
      height = 0.85,
      -- preview_cutoff = 120,
      prompt_position = "top",

      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 200 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.6)
          end
        end,
      },

      vertical = {
        width = 0.9,
        height = 0.95,
        preview_height = 0.5,
      },

      flex = {
        horizontal = {
          preview_width = 0.9,
        },
      },
    },

    selection_strategy = "reset",
    sorting_strategy = "descending",
    scroll_strategy = "cycle",
    color_devicons = true,

    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
  },
})

_ = require("telescope").load_extension("neoclip")
_ = require("telescope").load_extension("file_browser")
_ = require("telescope").load_extension("ui-select")
_ = require("telescope").load_extension("fzf")
_ = require("telescope").load_extension("dap")

vim.keymap.set("n", "<leader>cf", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
vim.keymap.set("n", "<space>fa", ":Telescope oldfiles<CR>")
vim.keymap.set("n", "<space>fb", ":Telescope buffers<CR>")
