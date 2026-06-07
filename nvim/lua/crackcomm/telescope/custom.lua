local builtin = require("telescope.builtin")
local lsp_opts = require("crackcomm.lsp.telescope.definitions").default_opts
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local lsp_rename = require("crackcomm.lsp.actions.rename_file")

local M = {}

function M.lsp_safe_rename(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if not selection then
    vim.notify("File Browser: No file selected to rename.", vim.log.levels.WARN)
    return
  end
  local old_path = selection.value

  vim.ui.input({
    prompt = "New Name: ",
    default = old_path,
    completion = "file",
  }, function(new_path_input)
    if not new_path_input or new_path_input == "" or new_path_input == old_path then
      vim.notify("File Browser: Rename cancelled.", vim.log.levels.INFO)
      return
    end

    local new_path
    if string.sub(new_path_input, 1, 1) == "/" then
      new_path = new_path_input
    else
      new_path = picker.cwd .. "/" .. new_path_input
    end

    lsp_rename(old_path, new_path)
    actions.close(prompt_bufnr)
  end)
end

M.oldfiles = function()
  builtin.oldfiles({
    cwd = vim.loop.cwd(),
    entry_maker = function(entry)
      local display = vim.fn.fnamemodify(entry, ":.")
      display = display:gsub("^./", "")
      return {
        value = entry,
        display = display,
        ordinal = display,
      }
    end,
  })
end

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
