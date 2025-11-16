local M = {}

-- Helper utility to manage progress reporting with Fidget.
-- This encapsulates the creation, updating, and completion of the progress indicator.
function M.create_reporter(client, total_steps, title)
  local progress = require("fidget.progress")
  local handle = progress.handle.create({
    title = title,
    message = "Initializing...",
    lsp_client = client,
    percentage = 0,
  })

  local current_step = 0

  return {
    -- Reports progress for the next step.
    step = function(message)
      current_step = current_step + 1
      local percentage = 0
      if total_steps > 0 then
        -- Calculate percentage based on completed steps.
        percentage = math.floor(((current_step - 1) / total_steps) * 100)
      end
      handle:report({ message = message, percentage = percentage })
    end,
    -- Completes and closes the progress indicator.
    finish = function()
      handle:report({ percentage = 100 })
      handle:finish()
    end,
  }
end

return M
