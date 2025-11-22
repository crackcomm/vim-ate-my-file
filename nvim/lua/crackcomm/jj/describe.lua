local a = require("plenary.async")
local common = require("crackcomm.common.init")
local jj_log = require("crackcomm.jj.log")

local create_progress_reporter = require("crackcomm.progress").create_reporter

local M = {}

M.generate_commit_message = function(opts)
  opts = opts or {}

  -- Create a Fidget progress reporter. A mock client is used for non-LSP tasks.
  local progress = create_progress_reporter({ name = "jj" }, 2, "JJ Describe")

  a.run(function()
    if not opts.rev then
      opts.rev = jj_log({ rev = "::@" })
    end

    progress.step("Generating commit message")

    local job = common.start_job({
      command = common.scripts .. "/jjcg.sh",
      args = { opts.rev },
      enable_recording = true,
    })
    common.check_job_error(job, "generating commit message")

    progress.step("Getting commit summary")

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
    progress.finish()
    if stdout then
      vim.schedule(function()
        vim.notify("jj: " .. stdout, vim.log.levels.INFO)
      end)
    end
  end)
end

return M
