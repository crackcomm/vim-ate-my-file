-- Telescope pickers for keymap_advisor

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.find_free_keymaps()
  local free_maps_finder = require("crackcomm.keymap_advisor.free")
  local results = free_maps_finder.get_free_keymaps()

  pickers
    .new({}, {
      prompt_title = "Find Free Keymaps (sorted by convenience)",
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          return {
            value = entry.keymap,
            display = string.format("%s (score: %.2f)", entry.keymap, entry.score),
            ordinal = entry.keymap,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.notify("Selected keymap: " .. selection.value)
          -- You can extend this to automatically start setting the keymap.
          vim.cmd.normal(":" .. "nmap " .. selection.value .. " ")
        end)
        return true
      end,
    })
    :find()
end

function M.show_keymap_usage()
  local tracker = require("crackcomm.keymap_advisor.tracker")
  local project = require("crackcomm.common.project")
  local current_root = project.find_root()

  local all_stats = {}

  local counts = tracker.get_counts()
  local stats_to_show = counts.global or {}

  for mode, maps in pairs(stats_to_show) do
    for lhs, count in pairs(maps) do
      local display_str = string.format("[%s] %-20s (global: %d)", mode, lhs, count)

      if current_root and counts[current_root] and counts[current_root][mode] and counts[current_root][mode][lhs] then
        local project_count = counts[current_root][mode][lhs]
        display_str = string.format("[%s] %-20s (project: %d, global: %d)", mode, lhs, project_count, count)
      end

      table.insert(all_stats, {
        mode = mode,
        lhs = lhs,
        count = count,
        display = display_str,
      })
    end
  end

  table.sort(all_stats, function(a, b)
    return a.count > b.count
  end)

  pickers
    .new({}, {
      prompt_title = "Keymap Usage Heatmap",
      finder = finders.new_table({
        results = all_stats,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display,
            ordinal = string.format("%s %s", entry.mode, entry.lhs),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

return M
