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
  cmd = cmd,
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
  before_init = function(_, config)
    local workspace_dir = vim.fn.getcwd()
    config.cmd = vim.list_extend(cmd, {
      "--compile-commands-dir=" .. workspace_dir,
      "--tweaks=-I" .. workspace_dir, -- Add the workspace directory as an include path
    })
  end,
}
