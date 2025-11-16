local create_progress_reporter = require("crackcomm.progress").create_reporter

local M = {}

function M.run(client, bufnr)
  if vim.b[bufnr] and vim.b[bufnr].is_saving then
    return
  end

  local capabilities = require("crackcomm.lsp.capabilities")

  local code_actions = capabilities.supported_code_actions(client, {
    "source.addMissingImports",
    "source.organizeImports",
    "source.removeUnusedImports",
  })

  -- If no special code actions are supported, perform a standard format.
  if #code_actions == 0 then
    local progress = create_progress_reporter(client, 1, "Formatting")
    progress.step("Running formatter...")
    vim.lsp.buf.format({ bufnr = bufnr })
    vim.cmd.write()
    progress.finish()
    return
  end

  -- If code actions are supported, run them sequentially before the final format.
  vim.b[bufnr].is_saving = true
  local progress = create_progress_reporter(client, #code_actions + 1, "Formatting")

  local function run_next_action(index)
    -- After all code actions, run the final format.
    if index > #code_actions then
      progress.step("Final formatting...")
      vim.lsp.buf.format({ bufnr = bufnr })
      vim.cmd.write()
      progress.finish()
      vim.schedule(function()
        vim.b[bufnr].is_saving = nil
      end)
      return
    end

    -- Run the current code action.
    local kind = code_actions[index]
    progress.step("Running " .. kind)

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      range = {
        start = { line = 0, character = 0 },
        ["end"] = { line = line_count, character = 0 },
      },
      context = { only = { kind }, diagnostics = {} },
    }

    vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function(err, result)
      if err then
        vim.notify("LSP code action error: " .. err.message, vim.log.levels.WARN)
      elseif result and #result > 0 then
        local action = result[1]
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
        if action.command then
          vim.lsp.buf.execute_command(action)
        end
      end
      -- Proceed to the next action in the sequence.
      run_next_action(index + 1)
    end)
  end

  run_next_action(1)
end

return M
