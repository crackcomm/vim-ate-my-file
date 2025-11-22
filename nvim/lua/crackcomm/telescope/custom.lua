local builtin = require("telescope.builtin")
local lsp_opts = require("crackcomm.lsp.telescope").default_opts
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

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

    local old_bufnr = vim.fn.bufnr(old_path)
    if old_bufnr ~= -1 then
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = old_bufnr })) do
        vim.lsp.buf_detach_client(old_bufnr, client.id)
      end
    end

    local ok, err = os.rename(old_path, new_path)
    if not ok then
      vim.notify("File Browser: Error renaming file: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    actions.close(prompt_bufnr)

    -- First, edit the new file. This handles the case where the buffer is in the
    -- last window, and also creates the new buffer for us.
    vim.cmd.edit(vim.fn.fnameescape(new_path))

    if old_bufnr ~= -1 then
      local new_bufnr = vim.api.nvim_get_current_buf()

      -- Find all windows that were displaying the old buffer and update them.
      local wins = vim.fn.win_findbuf(old_bufnr)
      for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == old_bufnr then
          vim.api.nvim_win_set_buf(win, new_bufnr)
        end
      end

      -- Now that no windows are showing the old buffer, it's safe to delete.
      if vim.api.nvim_buf_is_loaded(old_bufnr) then
        vim.api.nvim_buf_delete(old_bufnr, { force = true })
      end
    end

    vim.schedule(function()
      local old_uri = vim.uri_from_fname(old_path)
      local new_uri = vim.uri_from_fname(new_path)

      for _, client in ipairs(vim.lsp.get_clients()) do
        if client:supports_method("workspace/didRenameFiles") then
          client:notify("workspace/didRenameFiles", {
            files = { { oldUri = old_uri, newUri = new_uri } },
          })
        end
      end
      vim.notify(string.format("Renamed '%s' to '%s' and notified LSP.", old_path, new_path))
    end)
  end)
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
