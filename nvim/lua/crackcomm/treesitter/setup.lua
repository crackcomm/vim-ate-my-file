local ts = require("nvim-treesitter")

ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
  highlight = { enable = true },
})

local ensure_installed =
  { "c", "cpp", "lua", "vim", "vimdoc", "query", "go", "python", "javascript", "typescript", "rust" }
ts.install(ensure_installed)

vim.treesitter.language.register(
  "python",
  { "py", "pyi", "pyx", "pxd", "pxi", "bzl", "BUILD", "BUILD.bazel", "WORKSPACE" }
)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
