local themes = require("telescope.themes")
local lsp_opts = require("crackcomm.lsp.telescope").default_opts

local M = {}

function M.lsp_code_actions()
  local opts = themes.get_dropdown({
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  })

  require("telescope.builtin").lsp_code_actions(opts)
end

function M.lsp_references()
  require("telescope.builtin").lsp_references({
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
  })
end

function M.lsp_implementations()
  require("telescope.builtin").lsp_implementations(lsp_opts)
end

return setmetatable({}, {
  __index = function(_, k)
    -- reloader()

    if M[k] then
      return M[k]
    else
      return require("telescope.builtin")[k]
    end
  end,
})
