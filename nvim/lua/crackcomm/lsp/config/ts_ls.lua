local override = require("crackcomm.lsp.override")
local ts_util = require("nvim-lsp-ts-utils")

return {
  init_options = ts_util.init_options,
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },

  on_attach = function(client, bufnr)
    override.on_attach(client, bufnr)

    ts_util.setup({ auto_inlay_hints = true })
    ts_util.setup_client(client)
  end,
}
