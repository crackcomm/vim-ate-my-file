require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "python", "javascript", "typescript", "rust" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  indent = {
    enable = true,
    disable = { "rust", "ocaml" },
  },

  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 1024 * 1024 -- 1 MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = { "markdown" },
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "si",
      node_incremental = "sn",
      scope_incremental = "sc",
      node_decremental = "sv",
    },
  },

  -- move = {
  --   enable = true,
  --   set_jumps = true, -- whether to set jumps in the jumplist
  --   goto_next_start = {
  --     ["]m"] = "@function.outer",
  --     ["]]"] = "@class.outer",
  --   },
  --   goto_next_end = {
  --     ["]M"] = "@function.outer",
  --     ["]["] = "@class.outer",
  --   },
  --   goto_previous_start = {
  --     ["[m"] = "@function.outer",
  --     ["[["] = "@class.outer",
  --   },
  --   goto_previous_end = {
  --     ["[M"] = "@function.outer",
  --     ["[]"] = "@class.outer",
  --   },
  -- },

  modules = {},
})
