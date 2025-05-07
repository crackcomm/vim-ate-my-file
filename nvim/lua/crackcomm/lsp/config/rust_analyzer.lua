return {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = false,
      },
      files = {
        excludeDirs = { "bazel-out", "bazel-bin", "bazel-testlogs", "bazel-monorepo-ocxmr" },
      },
    },
  },
}
