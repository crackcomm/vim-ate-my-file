--- LSP Handlers overrides
local lsp_telescope = require("crackcomm.lsp.telescope")

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
    signs = {
      severity = { min = vim.diagnostic.severity.ERROR },
    },
    underline = {
      severity = { min = vim.diagnostic.severity.WARN },
    },
    virtual_text = true,
  })

vim.lsp.handlers["window/showMessage"] = require("crackcomm.lsp.show_message")

local M = {}

M.definition = function()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results_per_client, _, ctx)
    -- if exactly one location, jump there:
    local total = 0
    for _, r in pairs(results_per_client) do
      if r.result and not vim.tbl_isempty(r.result) then
        total = total + 1
      end
    end
    if total == 1 then
      for cid, r in pairs(results_per_client) do
        local loc = (type(r.result) == "table" and r.result[1] or r.result)
        vim.lsp.util.jump_to_location(loc, vim.lsp.get_client_by_id(cid).offset_encoding)
        return
      end
    end
    if total == 0 then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    -- otherwise show our picker
    lsp_telescope.pick("LSP Definitions", results_per_client, { context = ctx })
  end)
end

M.implementation = function()
  local params = vim.lsp.util.make_position_params(0, "utf-8")

  vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
    local bufnr = ctx.bufnr
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- In go code, I do not like to see any mocks for impls
    if ft == "go" then
      local new_result = vim.tbl_filter(function(v)
        return not string.find(v.uri, "mock_")
      end, result)

      if #new_result > 0 then
        result = new_result
      end
    end

    vim.lsp.handlers["textDocument/implementation"](err, result, ctx, config)
    vim.cmd([[normal! zz]])
  end)
end

M.restart = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP clients to restart for this buffer.", vim.log.levels.INFO)
    return
  end

  -- Get the IDs of the clients we are about to stop
  local client_ids = {}
  for _, client in ipairs(clients) do
    if client.name ~= "copilot" then
      table.insert(client_ids, client.id)
    end
  end

  -- Stop the clients
  vim.lsp.stop_client(client_ids)
  vim.notify("Stopping LSP clients...", vim.log.levels.INFO)

  -- Create a timer to periodically check if the clients have stopped
  local wait_timer = vim.uv.new_timer()
  --- Nil check
  if wait_timer == nil then
    vim.notify("Failed to create timer for LSP restart.", vim.log.levels.ERROR)
    return
  end

  local check_interval = 100 -- Check every 100ms
  local timeout = 5000 -- Give up after 5 seconds

  local function check_clients_stopped()
    timeout = timeout - check_interval
    if timeout <= 0 then
      vim.notify("LSP restart timed out.", vim.log.levels.ERROR)
      wait_timer:close()
      return
    end

    local all_stopped = true
    for _, id in ipairs(client_ids) do
      if vim.lsp.get_client_by_id(id) ~= nil then
        all_stopped = false -- At least one client is still running
        break
      end
    end

    if not all_stopped then
      return
    end

    if not wait_timer:is_closing() then
      wait_timer:close()
    end

    vim.notify("All LSP clients stopped. Reloading buffer...", vim.log.levels.INFO)

    -- All clients are confirmed to be stopped, now we can safely reload
    local view = vim.fn.winsaveview()
    vim.cmd("noautocmd write | edit")
    vim.fn.winrestview(view)
    vim.notify("LSP clients restarted.", vim.log.levels.INFO)
  end

  -- Start the timer
  wait_timer:start(0, check_interval, vim.schedule_wrap(check_clients_stopped))
end

return M
