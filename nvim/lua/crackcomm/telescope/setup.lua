local fb = require("telescope").extensions.file_browser
local nmap = require("crackcomm.keymap").nmap
local vmap = require("crackcomm.keymap").vmap

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

_ = require("telescope").load_extension("neoclip")
_ = require("telescope").load_extension("file_browser")
_ = require("telescope").load_extension("ui-select")
_ = require("telescope").load_extension("fzf")
_ = require("telescope").load_extension("dap")

local builtin = require("telescope.builtin")

local M = {}

-- Telescope resume
-- Telescope grep_string

M.browse_files = function(opts)
  opts = opts or {}
  -- builtin.file_browser({ path = vim.fn.expand("%:p:h"), select_buffer = true })
  fb.file_browser(vim.tbl_extend("force", {
    -- cwd = vim.fn.expand("%:p:h"),
    grouped = true,
    depth = 1,
    select_buffer = true,
  }, opts))
end

-- telescope builtins
nmap({ "<space>tt", builtin.builtin, { silent = true, desc = "telescope:" } })
nmap({ "<space>tr", builtin.resume, { silent = true, desc = "telescope:" } })

-- [h]ome
nmap({
  "<space>hf",
  function()
    M.browse_files({
      path = vim.fn.expand("~/x"),
      depth = 1,
      hide_parent_dir = true,
      initial_mode = "normal",
    })
  end,
  "telescope: [h]ome [f]iles",
})

-- [w]orkspace (cwd)
nmap({ "<space>wf", builtin.find_files, "telescope: [w]orkspace [f]iles" })
nmap({ "<space>wg", builtin.live_grep, "telescope: [w]orkspace [g]rep" })
nmap({
  "<space>wd",
  function()
    M.browse_files({
      depth = 1,
      files = true,
    })
  end,
  "telescope: [w]orkspace [d]irectories",
})

-- [b]uffers
nmap({
  "<space>bg",
  function()
    builtin.current_buffer_fuzzy_find({ reverse = false })
  end,
  "telescope: [b]uffer [g]rep",
})
nmap({
  "<space>bb",
  function()
    builtin.buffers({ initial_mode = "normal" })
  end,
  "telescope: [b]uffers",
})

-- current [f]ile
nmap({
  "<space>fg",
  function()
    builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
  end,
  "telescope: current [f]ile directory [g]rep",
})
nmap({
  "<space>ff",
  function()
    M.browse_files({
      path = vim.fn.expand("%:p:h"),
      prompt_path = true,
    })
  end,
  "telescope: current [f]ile directory [f]ile browser",
})

nmap({ "<space>of", builtin.oldfiles, "telescope: [o]ld [f]iles" })

-- [g]it
nmap({ "<space>gs", builtin.git_status, "telescope: [g]it [s]tatus" })
nmap({ "<space>gf", builtin.git_files, "telescope: [g]it [f]iles" })
nmap({ "<space>gl", builtin.git_commits, "telescope: [g]it [l]og" })
nmap({ "<space>gc", builtin.git_bcommits, "telescope: [g]it [c]ommits" })
vmap({ "<space>gc", builtin.git_bcommits_range, "telescope: [g]it [c]ommits" })

-- Check if Neovim was started with a directory argument
local args = vim.fn.argv()
if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
  -- Get the directory path from the argument
  local dir = args[1]

  -- Set an autocommand to run after Neovim finishes loading
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      builtin.find_files()
    end,
  })
end

return M
