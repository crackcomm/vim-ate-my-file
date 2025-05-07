return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT", -- Neovim uses LuaJIT
      },
      workspace = {
        library = { vim.env.VIMRUNTIME .. "/lua" },
        checkThirdParty = false,
      },
    },
  },
}
