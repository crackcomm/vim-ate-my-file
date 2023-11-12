local log = require("crackcomm.log")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local conf = require("telescope.config").values

local M = {}

-- check if WORKSPACE file exists
M.workspace_exists = function()
  local workspace = vim.fn.glob("WORKSPACE")
  if workspace == "" then
    log.error("WORKSPACE file not found")
    return false
  end
  return true
end

M.picker = function(callback, opts)
  if not M.workspace_exists() then
    return
  end

  opts = opts or {}
  callback = callback or print

  -- TODO: label
  -- Execute the Bazel query command
  local command = "bazel query --keep_going --noshow_progress --output=label \"kind(.*_binary, '//ocxmr/...')\""
  local output = vim.fn.system(command)

  -- Check if the command executed successfully
  if vim.v.shell_error ~= 0 then
    print("Error executing Bazel command")
    return
  end

  -- Split the output into lines
  local results = vim.split(output, "\n")
  -- Remove empty lines
  results = vim.tbl_filter(function(line)
    return line ~= ""
  end, results)

  -- Show results in Telescope picker
  if #results < 1 then
    callback(nil)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Select Bazel Target",
      finder = finders.new_table({
        results = results,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        local confirm = function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          callback(selection.value)
        end
        map("i", "<CR>", confirm)
        map("n", "<CR>", confirm)
        return true
      end,
    })
    :find()
end

M.build = function(label, callback, opts)
  opts = opts or {}

  local buf = nil
  if opts.log then
    vim.cmd("botright split | enew")

    buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_name(buf, "build" .. label)
  end

  local cmd = "bazel build " .. label
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and buf then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
      end
      callback(false, true)
    end,
    on_stderr = function(_, data)
      if data and buf then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
      end
      callback(false, true)
    end,
    on_exit = function(_, code)
      if code == 0 and buf then
        vim.api.nvim_buf_delete(buf, { force = true })
      elseif buf then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Bazel build failed" })
      end
      callback(true, code == 0)
    end,
  })
end

-- Remove the initial "//" and replace ":" with "/"
local function path_of_label(label)
  return label:gsub("^//", ""):gsub(":", "/")
end

-- Prepend "bazel-bin/" and concatenate with Neovim's current working directory
M.output_path = function(label)
  return vim.fn.getcwd() .. "/bazel-bin/" .. path_of_label(label)
end

M.main_module_name = function()
  local cwd = vim.fn.getcwd()
  local repo_name = vim.fn.fnamemodify(cwd, ":t")
  return repo_name:gsub("-", "_")
end

return M
