local fb = require("telescope").extensions.file_browser
local telescope = require("telescope")

telescope.setup({
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
    frecency = {
      auto_validate = true,
      db_safe_mode = false,
      matcher = "fuzzy",
    },

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
      display_stat = { size = true },
      use_fd = false, -- problems with /usr/...
      mappings = {
        ["i"] = {
          ["<A-c>"] = fb.actions.create,
          ["<S-CR>"] = fb.actions.create_from_prompt,
          ["<A-r>"] = fb.actions.rename,
          ["<A-m>"] = fb.actions.move,
          ["<A-y>"] = fb.actions.copy,
          ["<A-d>"] = fb.actions.remove,
          ["<C-o>"] = fb.actions.open,
          ["<C-g>"] = fb.actions.goto_parent_dir,
          ["<C-e>"] = fb.actions.goto_home_dir,
          ["<C-w>"] = fb.actions.goto_cwd,
          ["<C-t>"] = fb.actions.change_cwd,
          ["<C-f>"] = fb.actions.toggle_browser,
          ["<C-h>"] = fb.actions.toggle_hidden,
          ["<C-s>"] = fb.actions.toggle_all,
          ["<bs>"] = fb.actions.backspace,
        },
        ["n"] = {
          ["c"] = fb.actions.create,
          ["r"] = fb.actions.rename,
          ["m"] = fb.actions.move,
          ["y"] = fb.actions.copy,
          ["d"] = fb.actions.remove,
          ["o"] = fb.actions.open,
          ["g"] = fb.actions.goto_parent_dir,
          ["e"] = fb.actions.goto_home_dir,
          ["w"] = fb.actions.goto_cwd,
          ["t"] = fb.actions.change_cwd,
          ["f"] = fb.actions.toggle_browser,
          ["h"] = fb.actions.toggle_hidden,
          ["s"] = fb.actions.toggle_all,
        },
      },
    },
  },

  defaults = {
    winblend = 0,
    -- initial_mode = "normal",
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.95,
      height = 0.90,
      preview_cutoff = 120,
      prompt_position = "top",

      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 100 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.8)
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
          preview_width = 1.2,
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

    path_display = function(_, path)
      local home = os.getenv("HOME")
      local substitutions = {
        [home .. "/x/dot-repo/nvim"] = "~/nvim",
        [home .. "/x/monorepo-ocxmr"] = "~/ocxmr",
        [home .. "/.local/nvim-linux64/share/nvim/runtime/lua/vim"] = "/vim",
        [home] = "~",
      }
      for k, v in pairs(substitutions) do
        if path:sub(1, #k) == k then
          path = v .. path:sub(#k + 1)
        end
      end
      return path
    end,
  },
})

local extensions_to_load = {
  "ui-select",
  "neoclip",
  "file_browser",
  "fzf",
  "dap",
  "frecency",
}
for _, ext in ipairs(extensions_to_load) do
  pcall(telescope.load_extension, ext) -- Use pcall for safety
end
