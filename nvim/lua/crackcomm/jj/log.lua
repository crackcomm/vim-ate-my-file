local a = require("plenary.async")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local ts_utils = require("telescope.utils")
local jj_root = require("crackcomm.jj.common").jj_root

return function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or jj_root()
  if not opts.cwd then
    return
  end
  opts.rev = opts.rev or "open()"

  local cmd = {
    "jj",
    "log",
    "-r=" .. opts.rev,
    "--no-pager",
    "--no-graph",
    "-T",
    'change_id.shortest(7) ++ " " ++ description.first_line() ++ "\n"',
  }

  local lines = ts_utils.get_os_command_output(cmd, opts.cwd)

  -- turn "pkznsor fix(...)" into { value = "pkznsor", display = ..., ordinal = ... }
  local function entry_maker(line)
    local rev, msg = line:match("^(%S+)%s+(.*)")
    if not rev then
      return
    end
    return {
      value = rev,
      ordinal = rev .. " " .. msg,
      display = ("%s  %s"):format(rev, msg),
    }
  end

  local diff_previewer = previewers.new_termopen_previewer({
    get_command = function(entry)
      return { "jj", "diff", "--color=always", "-r", entry.value }
    end,
  })

  return a.wrap(function(cb)
    pickers
      .new(opts, {
        prompt_title = "JJ Log",
        finder = finders.new_table({
          results = lines,
          entry_maker = entry_maker,
        }),
        previewer = diff_previewer,
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, _)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            cb(selection and selection.value)
          end)
          return true
        end,
      })
      :find()
  end, 1)()
end
