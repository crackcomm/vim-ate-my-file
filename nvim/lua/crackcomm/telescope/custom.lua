local builtin = require("telescope.builtin")
local lsp_opts = require("crackcomm.lsp.telescope").default_opts

local M = {}

M.lsp_references = function()
  builtin.lsp_references({
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
  })
end

M.lsp_implementations = function()
  builtin.lsp_implementations(lsp_opts)
end

M.frecency = function(opts)
  local frecency = require("telescope").extensions.frecency.frecency
  opts = opts or {}
  opts.workspace = opts.workspace or "CWD"
  opts.hide_current_buffer = opts.hide_current_buffer or true
  return frecency(opts)
end

M.browse_files = function(opts)
  local fb = require("telescope").extensions.file_browser
  opts = opts or {}
  fb.file_browser(vim.tbl_extend("force", {
    grouped = true,
    depth = 1,
    select_buffer = true,
  }, opts))
end

-- TODO
return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require("telescope.builtin")[k]
    end
  end,
})
