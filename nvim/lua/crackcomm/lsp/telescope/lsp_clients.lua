-- Telescope finder for LSP clients.

local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")

local function restart_client(bufnr)
  local picker = action_state.get_current_picker(bufnr)
  local action_name = "lsp.restart_client"
  picker:delete_selection(function(selection)
    local client = vim.lsp.get_client_by_id(selection.value)
    if client then
      client:_restart(true)
      utils.notify(action_name, {
        msg = string.format("Restarting LSP client: %s", selection.value),
        level = "INFO",
      })
    end
  end)
end

--- Shows a telescope picker with all active LSP clients.
---
--- @param opts table?
return function(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    initial_mode = "normal",
  })

  local picker_opts = {
    prompt_title = "LSP Clients",
    finder = finders.new_table({
      results = vim.lsp.get_clients({ bufnr = opts.bufnr }),
      --- @param entry vim.lsp.Client
      entry_maker = function(entry)
        local display_dir = utils.transform_path({
          path_display = { "smart" },
        }, entry.root_dir or "")
        return {
          value = entry.id,
          ordinal = entry.id,
          display = ("%s id=%s (%s)"):format(entry.name, entry.id, display_dir),
        }
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      map("n", "r", restart_client)
      actions.select_default:replace(function()
        restart_client(prompt_bufnr)
        actions.close(prompt_bufnr)
      end)
      return true
    end,
  }

  pickers.new(opts, picker_opts):find()
end
