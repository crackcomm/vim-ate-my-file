return {
  cmd = { "bazel-lsp" },
  filetypes = { "bzl" },
  root_dir = function(bufnr, on_dir)
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.dirname(vim.fs.find("WORKSPACE", { path = filepath, upward = true })[1])
    on_dir(root or vim.fn.getcwd())
  end,
}
