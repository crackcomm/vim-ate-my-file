local cmd = {
  "clangd",
  "--log=error",
  "--completion-style=detailed",
  "--background-index",
  "--clang-tidy",
  "--header-insertion=iwyu",
  "--offset-encoding=utf-16",
}

return {
  cmd = function(dispatchers)
    local workspace_dir = vim.fn.getcwd()
    local lsp_cmd = vim.list_extend(cmd, {
      "--compile-commands-dir=" .. workspace_dir,
      "--tweaks=-I" .. workspace_dir, -- Add the workspace directory as an include path
    })
    return vim.lsp.rpc.start(lsp_cmd, dispatchers)
  end,
  cmd_env = {
    USER = "crackcomm",
  },
  init_options = {
    clangdFileStatus = true,
  },
  filetypes = {
    "c",
    "h",
    "hh",
    "hpp",
    "cpp",
    "cc",
    "cxx",
    "hxx",
    "arduino",
  },
  root_dir = vim.fn.getcwd(),
}
