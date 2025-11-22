local override = require("crackcomm.lsp.override")

return {
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

  on_attach = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil

    override.on_attach(client, bufnr)
  end,
}
