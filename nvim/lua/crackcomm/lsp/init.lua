local override = require("crackcomm.lsp.override")
local lspconfig = require("lspconfig")

local servers = {
  pyright = require("crackcomm.lsp.config.pyright"),
  clangd = require("crackcomm.lsp.config.clangd"),
  gopls = require("crackcomm.lsp.config.gopls"),
  ts_ls = require("crackcomm.lsp.config.ts_ls"),

  ocamllsp = {
    cmd = { "ocamllsp", "--fallback-read-dot-merlin" },
    settings = {
      codelens = { enable = true },
      syntaxDocumentation = { enable = true },
      server_capabilities = {
        semanticTokensProvider = nil,
      },
    },

    get_language_id = function(_, ftype)
      return ftype
    end,
  },

  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT", -- Neovim uses LuaJIT
        },
        workspace = {
          library = { vim.env.VIMRUNTIME .. "/lua" },
          checkThirdParty = false,
        },
      },
    },
  },

  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          enable = false,
        },
        files = {
          excludeDirs = { "bazel-out", "bazel-bin", "bazel-testlogs", "bazel-monorepo-ocxmr" },
        },
      },
    },
  },

  nil_ls = {
    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixfmt" },
        },
      },
    },
  },

  marksman = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "md", "markdown.pandoc" },
    single_file_support = true,
  },

  taplo = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    single_file_support = true,
  },
}

require("mason").setup()
require("mason-lspconfig").setup({
  automatic_installation = false,
  ensure_installed = { "jsonls", "rust_analyzer", "nil_ls", "marksman", "taplo" },
})

local function get_merged_config(config)
  return vim.tbl_deep_extend("force", {
    on_init = override.on_init,
    on_attach = override.on_attach,
    capabilities = override.capabilities,
  }, config)
end

for server, config in pairs(servers) do
  lspconfig[server].setup(get_merged_config(config))
end

if vim.fn.executable("bazel-lsp") == 1 then
  local function bazel_lsp()
    vim.lsp.start(get_merged_config({
      name = "bazel-lsp",
      cmd = { "bazel-lsp" },
      -- root_dir = vim.lsp.util.root_pattern("WORKSPACE", "BUILD"),
      filetypes = { "bzl" },
    }))
  end

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.bzl", "*.bazel", "BUILD", "WORKSPACE", "*.sky" },
    callback = bazel_lsp,
  })
end
