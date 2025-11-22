local override = require("crackcomm.lsp.override")

local servers = {
  pyright = require("crackcomm.lsp.config.pyright"),
  clangd = require("crackcomm.lsp.config.clangd"),
  gopls = require("crackcomm.lsp.config.gopls"),
  ts_ls = require("crackcomm.lsp.config.ts_ls"),
  ocamllsp = require("crackcomm.lsp.config.ocamllsp"),
  lua_ls = require("crackcomm.lsp.config.lua_ls"),
  rust_analyzer = require("crackcomm.lsp.config.rust_analyzer"),
  nixd = require("crackcomm.lsp.config.nixd"),
  marksman = require("crackcomm.lsp.config.marksman"),
  taplo = require("crackcomm.lsp.config.taplo"),
  bazel_lsp = require("crackcomm.lsp.config.bazel_lsp"),
}

require("mason").setup()
require("mason-lspconfig").setup({
  automatic_installation = false,
  ensure_installed = { "jsonls", "marksman", "taplo" },
})

local function get_merged_config(config)
  return vim.tbl_deep_extend("force", {
    on_init = override.on_init,
    on_attach = override.on_attach,
    capabilities = override.capabilities,
  }, config)
end

for server, config in pairs(servers) do
  local cfg = get_merged_config(config)
  local cmd = cfg.cmd or vim.lsp.config[server].cmd
  if not cmd then
    vim.notify("No command specified for LSP server: " .. server, vim.log.levels.WARN)
    return
  end
  if type(cmd) == "function" or vim.fn.executable(cmd[1]) == 1 then
    vim.lsp.config(server, cfg)
    vim.lsp.enable(server)
  end
end

