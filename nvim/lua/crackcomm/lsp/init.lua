local override = require("crackcomm.lsp.override")
local lspconfig = require("lspconfig")

local servers = {
  pyright = {
    settings = {
      python = {
        pythonPath = "/usr/bin/python3.10",
        analysis = {
          pythonVersion = "3.10",
        },
      },
    },
  },
  clangd = require("crackcomm.lsp.config.clangd"),
  gopls = require("crackcomm.lsp.config.gopls"),
  ts_ls = require("crackcomm.lsp.config.ts_ls"),

  ocamllsp = {
    cmd = { "esy", "ocamllsp" },
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

  rust_analyzer = {},
}

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "jsonls", "rust_analyzer" },
})

local setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = vim.tbl_deep_extend("force", {
    on_init = override.on_init,
    on_attach = override.on_attach,
    capabilities = override.capabilities,
  }, config)

  lspconfig[server].setup(config)
end

for server, config in pairs(servers) do
  setup_server(server, config)
end
