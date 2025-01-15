local override = require("crackcomm.lsp.override")
local lspconfig = require("lspconfig")

local servers = {
  pyright = require("crackcomm.lsp.config.pyright"),
  clangd = require("crackcomm.lsp.config.clangd"),
  gopls = require("crackcomm.lsp.config.gopls"),
  ts_ls = require("crackcomm.lsp.config.ts_ls"),

  ocamllsp = {
    cmd = { "ocamllsp" },
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
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
    },
  },

  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          enable = false,
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
}

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "jsonls", "rust_analyzer", "nil_ls" },
})

local function config_with_defaults(config)
  return vim.tbl_deep_extend("force", {
    on_init = override.on_init,
    on_attach = override.on_attach,
    capabilities = override.capabilities,
  }, config)
end

for server, config in pairs(servers) do
  local default_config = config_with_defaults(config)
  lspconfig[server].setup(default_config)
end

local function bazel_lsp()
  vim.lsp.start(config_with_defaults({
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
