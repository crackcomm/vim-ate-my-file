local a = require("plenary.async")
local Job = require("plenary.job")

local M = {}

M.home = os.getenv("HOME")
M.scripts = M.home .. "/x/dot-repo/scripts"

M.start_job = a.wrap(function(opts, cb)
  opts.on_exit = function(j)
    cb(j)
  end
  --- @diagnostic disable-next-line: missing-fields
  local job = Job:new(opts)
  job:start()
end, 2)

M.raise_job_error = function(job, when)
  local stdout = table.concat(job:result() or {}, "\n")
  local stderr = table.concat(job:stderr_result() or {}, "\n")
  errorf("An error occurred while %s with exit code %d. stderr: `%s` stdout: `%s`", when, job.code, stderr, stdout)
end

M.check_job_error = function(job, when)
  if job.code ~= 0 then
    M.raise_job_error(job, when)
  end
end

M.get_os_command_output = function(args)
  local job = M.start_job({
    command = args[1],
    args = vim.list_slice(args, 2),
    enable_recording = true,
  })
  M.check_job_error(job, "getting output for " .. table.concat(args, " "))
  return job.code, table.concat(job:result() or {}, "\n")
end

return M
