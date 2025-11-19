return {
  settings = {
    nixd = {
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        enableExprDiagnostics = true,
      },
    },
  },
}
