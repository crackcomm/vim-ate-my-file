local a = require("plenary.async")
local common = require("crackcomm.common")
local jj_log = require("crackcomm.jj.log")

local M = {}

M.generate_commit_message = function(opts)
  opts = opts or {}
  a.run(function()
    if not opts.rev then
      opts.rev = jj_log({ rev = "::@" })
    end

    local job = common.start_job({
      command = common.scripts .. "/jjcg.sh",
      args = { opts.rev },
      enable_recording = true,
    })
    common.check_job_error(job, "generating commit message")

    local _, stdout = common.get_os_command_output({
      "jj",
      "log",
      "-r",
      opts.rev,
      "--no-graph",
      "-T",
      "description.first_line()",
    })

    return stdout
  end, function(stdout)
    if stdout then
      vim.schedule(function()
        vim.notify("jj: " .. stdout, vim.log.levels.INFO)
      end)
    end
  end)
end

return M
