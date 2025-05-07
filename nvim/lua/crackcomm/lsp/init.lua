local override = require("crackcomm.lsp.override")
local lspconfig = require("lspconfig")

local servers = {
  pyright = require("crackcomm.lsp.config.pyright"),
  clangd = require("crackcomm.lsp.config.clangd"),
  gopls = require("crackcomm.lsp.config.gopls"),
  ts_ls = require("crackcomm.lsp.config.ts_ls"),
  ocamllsp = require("crackcomm.lsp.config.ocamllsp"),
  lua_ls = require("crackcomm.lsp.config.lua_ls"),
  rust_analyzer = require("crackcomm.lsp.config.rust_analyzer"),
  nil_ls = require("crackcomm.lsp.config.nil_ls"),
  marksman = require("crackcomm.lsp.config.marksman"),
  taplo = require("crackcomm.lsp.config.taplo"),
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
