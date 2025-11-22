local capabilities = require("crackcomm.lsp.capabilities")
local create_progress_reporter = require("crackcomm.common.progress").create_reporter

local M = {}

local function apply_code_action(client, bufnr, kind, on_complete)
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
    local ok, err_msg = pcall(function()
      if err then
        vim.notify("LSP code action error: " .. err.message, vim.log.levels.WARN)
      elseif result and #result > 0 then
        local action = result[1]
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
        if action.command then
          vim.lsp.buf_request(bufnr, "workspace/executeCommand", {
            command = action.command,
            arguments = action.arguments,
            workDoneToken = action.workDoneToken,
          })
        end
      end
    end)

    if not ok then
      vim.notify("Error processing code action '" .. kind .. "': " .. tostring(err_msg), vim.log.levels.WARN)
    end

    on_complete()
  end)
end

function M.apply_code_actions(client, bufnr, on_complete)
  local code_actions = capabilities.supported_code_actions(client, {
    "source.addMissingImports",
    "source.organizeImports",
    "source.removeUnusedImports",
  })

  -- If no special code actions are supported, perform a standard format.
  if #code_actions == 0 then
    on_complete()
    return
  end

  -- If code actions are supported, run them sequentially before the final format.
  local progress = create_progress_reporter(client, #code_actions, "LSP Code Actions")

  local function run_next_action(index)
    -- After all code actions, run the final format.
    if index > #code_actions then
      progress:finish()
      on_complete()
      return
    end

    -- Run the current code action.
    local kind = code_actions[index]
    progress.step("Running " .. kind)

    apply_code_action(client, bufnr, kind, function()
      run_next_action(index + 1)
    end)
  end

  run_next_action(1)
end

return M
