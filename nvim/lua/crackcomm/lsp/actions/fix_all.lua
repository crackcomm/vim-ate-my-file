local M = {}

local log = require("crackcomm.log")
local MAX_ITERATIONS = 50
local RETRY_DELAY = 500
local MAX_RETRIES = 3

local function get_diagnostics(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr)
  -- Sort top-to-bottom
  table.sort(diagnostics, function(a, b)
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end
    return a.col < b.col
  end)
  return diagnostics
end

local function get_quickfix_actions(bufnr, diagnostic, callback)
  local range = {
    start = { line = diagnostic.lnum, character = diagnostic.col },
    ["end"] = { line = diagnostic.end_lnum or diagnostic.lnum, character = diagnostic.end_col or diagnostic.col },
  }

  local lsp_diag = (diagnostic.user_data and diagnostic.user_data.lsp_diagnostic)
    or {
      range = range,
      severity = diagnostic.severity,
      message = diagnostic.message,
      source = diagnostic.source,
      code = diagnostic.code,
    }

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = range,
    context = {
      diagnostics = { lsp_diag },
      only = { "quickfix" },
    },
  }

  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
    local actions = {}
    for client_id, r in pairs(results) do
      if r.result then
        for _, action in ipairs(r.result) do
          local kind = action.kind or ""
          if kind == "" or kind:sub(1, 8) == "quickfix" then
            table.insert(actions, { client_id = client_id, action = action })
          end
        end
      end
    end
    callback(actions)
  end)
end

local function apply_action(bufnr, item, callback)
  local client = vim.lsp.get_client_by_id(item.client_id)
  if not client then
    callback(false)
    return
  end

  local action = item.action
  log.info(string.format("Applying fix: %s", action.title or "unnamed"))

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end

  if action.command then
    local req_params = type(action.command) == "table" and action.command
      or {
        command = action.command,
        arguments = action.arguments,
      }
    vim.lsp.buf_request(bufnr, "workspace/executeCommand", req_params, function(err)
      if err then
        log.error(string.format("Command failed: %s", vim.inspect(err)))
      end
      callback(true)
    end)
  else
    callback(true)
  end
end

local function fix_next(bufnr, diagnostics, idx, callback)
  if idx > #diagnostics then
    callback(false)
    return
  end

  get_quickfix_actions(bufnr, diagnostics[idx], function(actions)
    local action_to_apply
    if #actions == 1 then
      action_to_apply = actions[1]
    elseif #actions > 1 then
      -- If multiple, look for a preferred one
      for _, a in ipairs(actions) do
        if a.action.isPreferred then
          action_to_apply = a
          break
        end
      end
    end

    if action_to_apply then
      apply_action(bufnr, action_to_apply, function(success)
        callback(success)
      end)
    else
      fix_next(bufnr, diagnostics, idx + 1, callback)
    end
  end)
end

function M.fix_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local iterations = 0
  local retries = 0
  local handle

  local ok, fidget_progress = pcall(require, "fidget.progress")
  if ok then
    handle = fidget_progress.handle.create({
      title = "Applying Fixes",
      message = "In progress...",
    })
  end

  local function loop()
    iterations = iterations + 1
    if iterations > MAX_ITERATIONS then
      if handle then
        handle:finish()
      end
      vim.notify("Fix all: Reached max iterations", vim.log.levels.WARN)
      return
    end

    local diagnostics = get_diagnostics(bufnr)
    if #diagnostics == 0 then
      if handle then
        handle:finish()
      end
      vim.notify("Fix all: Complete", vim.log.levels.INFO)
      return
    end

    fix_next(bufnr, diagnostics, 1, function(applied)
      if applied then
        retries = 0
        -- Wait a bit for diagnostics to update
        vim.defer_fn(loop, 500)
      else
        if retries < MAX_RETRIES and #diagnostics > 0 then
          retries = retries + 1
          log.trace(
            string.format(
              "No fixes found, but %d diagnostics remain. Retrying (%d/%d) in %dms...",
              #diagnostics,
              retries,
              MAX_RETRIES,
              RETRY_DELAY
            )
          )
          vim.defer_fn(loop, RETRY_DELAY)
        else
          if handle then
            handle:finish()
          end
          vim.notify("Fix all: No more applicable fixes found", vim.log.levels.INFO)
        end
      end
    end)
  end

  loop()
end

return M
