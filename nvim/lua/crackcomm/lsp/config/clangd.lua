return {
  cmd = {
    "clangd",
    "--background-index",
    "--suggest-missing-includes",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--offset-encoding=utf-16",
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
  },
}
