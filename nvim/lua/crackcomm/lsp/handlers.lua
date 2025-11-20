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
  local current_bufnr = vim.api.nvim_get_current_buf()
  local clients_for_current_buf = vim.lsp.get_clients({ bufnr = current_bufnr })

  if #clients_for_current_buf == 0 then
    vim.notify("No LSP clients attached to this buffer.", vim.log.levels.INFO)
    return
  end

  -- This table will store everything we need to restart the clients correctly.
  -- Keyed by client.id for easy lookup.
  -- Format: { [client.id] = { config = client.config, bufs = { bufnr1, bufnr2, ... } } }
  local clients_to_restart = {}

  -- 1. Identify which clients to restart based on the current buffer.
  for _, client in ipairs(clients_for_current_buf) do
    if client.name ~= "copilot" and client.config and client.config.cmd then
      clients_to_restart[client.id] = {
        config = vim.deepcopy(client.config), -- Use deepcopy to avoid modifying the original
        bufs = {},
      }
    end
  end

  if vim.tbl_isempty(clients_to_restart) then
    vim.notify("No restartable LSP clients found (excluding copilot).", vim.log.levels.INFO)
    return
  end

  -- 2. Find ALL buffers that were being served by these exact clients.
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if clients_to_restart[client.id] then
          table.insert(clients_to_restart[client.id].bufs, bufnr)
        end
      end
    end
  end

  -- 3. Stop the identified clients.
  local client_ids_to_stop = vim.tbl_keys(clients_to_restart)
  vim.lsp.stop_client(client_ids_to_stop)
  vim.notify("Stopping LSP clients...", vim.log.levels.INFO)

  -- 4. Wait for the clients to fully terminate.
  local wait_timer = vim.uv.new_timer()
  if not wait_timer then
    vim.notify("Failed to create timer for LSP restart.", vim.log.levels.ERROR)
    return
  end

  local check_interval = 100
  local timeout = 5000

  local function check_clients_stopped()
    timeout = timeout - check_interval
    if timeout <= 0 then
      vim.notify("LSP restart timed out waiting for clients to stop.", vim.log.levels.ERROR)
      wait_timer:close()
      return
    end

    local all_stopped = true
    for _, id in ipairs(client_ids_to_stop) do
      if vim.lsp.get_client_by_id(id) ~= nil then
        all_stopped = false
        break
      end
    end

    if not all_stopped then
      return -- Not stopped yet, timer will run again.
    end

    -- Clients are confirmed to be stopped.
    wait_timer:close()

    -- 5. THE CORE FIX: Manually restart each client and re-attach its buffers.
    for _, data in pairs(clients_to_restart) do
      local config = data.config
      local bufs_to_attach = data.bufs

      if #bufs_to_attach == 0 then
        goto continue -- Skips this client if it had no buffers
      end

      -- The `on_attach` function runs only AFTER the client is initialized.
      -- This is the SAFE place to do things that require a running client.
      local original_on_attach = config.on_attach
      config.on_attach = function(new_client, initial_bufnr)
        -- First, run the user's original on_attach function to preserve all functionality.
        if original_on_attach then
          original_on_attach(new_client, initial_bufnr)
        end

        -- Now, attach the client to all the *other* buffers it was serving.
        -- The `initial_bufnr` is already attached by the `vim.lsp.start` call.
        for _, bufnr in ipairs(bufs_to_attach) do
          if bufnr ~= initial_bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            vim.lsp.buf_attach_client(bufnr, new_client.id)
          end
        end
      end

      -- Use vim.lsp.start which is the modern, high-level way to start a client.
      -- It needs a buffer to start with; we'll use the first one from our list.
      -- This call will start the server and attach it to the `initial_bufnr`,
      -- which then correctly triggers our modified `on_attach` function.
      vim.lsp.start(vim.tbl_extend("force", config, { bufnr = bufs_to_attach[1] }))

      ::continue::
    end
  end

  wait_timer:start(0, check_interval, vim.schedule_wrap(check_clients_stopped))
end

-- Copy all diagnostics from the current buffer to the system clipboard
function M.copy_all_diagnostics()
  local bufnr = 0
  local diagnostics = vim.diagnostic.get(bufnr)

  if vim.tbl_isempty(diagnostics) then
    vim.notify("No diagnostics found", vim.log.levels.INFO)
    return
  end

  -- Get workspace root (prefer LSP, fallback to cwd)
  local workspace_roots = vim.lsp.buf.list_workspace_folders()
  local root = (#workspace_roots > 0) and workspace_roots[1] or vim.fn.getcwd()

  -- Normalize path to remove trailing slash
  root = root:gsub("/+$", "")

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local relname = filename:gsub("^" .. vim.pesc(root) .. "/", "")

  local lines = {}
  for _, d in ipairs(diagnostics) do
    local line = string.format(
      "%s:%d:%d: [%s] %s",
      relname,
      d.lnum + 1,
      d.col + 1,
      vim.diagnostic.severity[d.severity] or "Unknown",
      d.message:gsub("\n", " ")
    )
    table.insert(lines, line)
  end

  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. #diagnostics .. " diagnostics to clipboard", vim.log.levels.INFO)
end

return M
