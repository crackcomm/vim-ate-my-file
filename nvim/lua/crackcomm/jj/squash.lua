local async = require("plenary.async")
local hunks = R("crackcomm.jj.hunks")
local common = R("crackcomm.jj.common")
local scripts = require("crackcomm.common").scripts
local Job = require("plenary.job")

local M = {}

M.squash_to_parent = async.void(function(patch_dir)
  if not hunks.has_hunks(true) then
    vim.notify("No hunks to squash", vim.log.levels.WARN)
    return
  end
  if patch_dir == nil then
    patch_dir = hunks.write_patches(nil, true)
  end

  local args = {
    "squash",
    "--to",
    "@-",
    "-i",
    string.format(
      '--config=ui.diff-editor=["%s", "$left", "$right", "$output", "%s"]',
      scripts .. "/jj-nvim-patch.sh",
      patch_dir
    ),
  }

  --- @diagnostic disable-next-line: missing-fields
  local job = Job:new({
    command = "jj",
    args = args,
    cwd = common.jj_root(),
    enable_recording = true,
  })
  job:sync(10000) -- TODO can be made async

  if job.code ~= 0 then
    local err = table.concat(job:stderr_result() or {}, "\n")
    if err == "" then
      err = "(no stderr output)"
    end
    vim.notify("jj squash failed:\n" .. err, vim.log.levels.ERROR)
    return
  end

  hunks.clear_marks()
end)

function M.squash_to_new_parent()
  if not hunks.has_hunks(true) then
    vim.notify("No hunks to squash")
    return
  end
  common.new_parent()
  M.squash_to_parent()
end

return M
