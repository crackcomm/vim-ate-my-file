local lspconfig = require("lspconfig")

local gopkgsdriver = vim.fn.stdpath("config") .. "/scripts/gopackagesdriver.sh"

return {
  on_new_config = function(config, root_dir)
    local workspace = root_dir .. "/WORKSPACE"
    if vim.loop.fs_stat(workspace) ~= nil then
      config.cmd_env = {
        GOPACKAGESDRIVER = gopkgsdriver,
      }
    end
  end,
  root_dir = function(fname)
    return lspconfig.util.find_git_ancestor(fname)
  end,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        nillness = true,
        unusedwrites = true,
        useany = true,
        unusedvariable = true,
      },

      codelenses = {
        generate = true,
        gc_details = false,
        test = true,
        tidy = true,
        run_vulncheck_exp = true,
        upgrade_dependency = true,
      },

      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      linksInHover = false,
      completionDocumentation = true,
      deepCompletion = true,
      semanticTokens = false,
      matcher = "Fuzzy", -- default
      -- diagnosticsDelay = "100ms",
      symbolMatcher = "Fuzzy", -- default is FastFuzzy

      hints = {
        -- assignVariableTypes = true,
        -- compositeLiteralFields = true,
        -- compositeLiteralTypes = true,
        -- constantValues = true,
        -- functionTypeParameters = true,
        -- parameterNames = true,
        rangeVariableTypes = true,
      },
      directoryFilters = {
        "-**/node_modules",
        "-/tmp",
      },
    },
  },

  flags = {
    debounce_text_changes = 200,
  },

  capabilities = {
    textDocument = {
      completion = {
        completionItem = {},
        contextSupport = true,
        dynamicRegistration = true,
      },
    },
  },

  server_capabilities = {
    semanticTokensProvider = {
      range = true,
    },
  },
}
