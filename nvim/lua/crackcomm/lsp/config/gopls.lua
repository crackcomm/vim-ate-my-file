local gopkgsdriver = vim.fn.stdpath("config") .. "/scripts/gopackagesdriver.sh"

return {
  --- @param dispatchers vim.lsp.rpc.Dispatchers
  --- @param config vim.lsp.ClientConfig
  cmd = function(dispatchers, config)
    local env = {}
    local workspace = vim.uv.fs_stat(config.root_dir .. "/WORKSPACE")
    local git = vim.uv.fs_stat(config.root_dir .. "/.git")
    if workspace and git then
      env["GOPACKAGESDRIVER"] = gopkgsdriver
    end
    return vim.lsp.rpc.start({ "gopls" }, dispatchers, { env = env })
  end,
  --- Root directory is determined by the `go.mod` file.
  root_dir = function(bufnr, on_dir)
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.dirname(vim.fs.find("go.mod", { path = filepath, upward = true })[1])
    on_dir(root or vim.fn.getcwd())
  end,
  --- Reuse client for bazel-generated sources like protobufs.
  --- @param client vim.lsp.Client
  --- @param config vim.lsp.ClientConfig
  reuse_client = function(client, config)
    if client.name ~= "gopls" then
      return false
    end
    if client.root_dir == config.root_dir then
      return true
    end
    -- We want to reuse client, for example for:
    -- ~/.cache/bazel/_bazel_pah/.../execroot/_main/bazel-out/k8-fastbuild/bin/ctx/service.connect.go
    -- But not for:
    -- ~/.cache/bazel/_bazel_pah/.../external/gazelle++go_deps+io_etcd_go_bbolt/tx.go
    return string.gmatch(config.root_dir, "execroot/_main")()
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
