--- Renames a file, replaces old buffers with the new buffer and notifies LSP.
---
--- @param old_path string Path to the file.
--- @param new_path string New, absolute path.
return function(old_path, new_path)
  if not new_path or new_path == "" or new_path == old_path then
    return
  end

  local old_bufnr = vim.fn.bufnr(old_path)
  if old_bufnr ~= -1 then
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = old_bufnr })) do
      vim.lsp.buf_detach_client(old_bufnr, client.id)
    end
  end

  local ok, err = os.rename(old_path, new_path)
  if not ok then
    vim.notify("File Browser: Error renaming file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  -- First, edit the new file. This handles the case where the buffer is in the
  -- last window, and also creates the new buffer for us.
  vim.cmd.edit(vim.fn.fnameescape(new_path))

  if old_bufnr ~= -1 then
    local new_bufnr = vim.api.nvim_get_current_buf()

    -- Find all windows that were displaying the old buffer and update them.
    local wins = vim.fn.win_findbuf(old_bufnr)
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == old_bufnr then
        vim.api.nvim_win_set_buf(win, new_bufnr)
      end
    end

    -- Now that no windows are showing the old buffer, it's safe to delete.
    if vim.api.nvim_buf_is_loaded(old_bufnr) then
      vim.api.nvim_buf_delete(old_bufnr, { force = true })
    end
  end

  vim.schedule(function()
    local old_uri = vim.uri_from_fname(old_path)
    local new_uri = vim.uri_from_fname(new_path)

    for _, client in ipairs(vim.lsp.get_clients()) do
      if client:supports_method("workspace/didRenameFiles") then
        client:notify("workspace/didRenameFiles", {
          files = { { oldUri = old_uri, newUri = new_uri } },
        })
      end
    end
  end)
end
