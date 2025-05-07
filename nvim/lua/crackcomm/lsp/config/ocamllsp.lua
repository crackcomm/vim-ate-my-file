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
}
