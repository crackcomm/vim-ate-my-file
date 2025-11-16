local M = {}

function M.setup()
  vim.keymap.set("n", "ss", function()
    local has_lsp_formatting = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
        has_lsp_formatting = true
        break
      end
    end

    -- if LSP supports formatting → just `:w`
    if has_lsp_formatting then
      vim.cmd("write")
      return
    end

    vim.cmd("Neoformat")
    vim.cmd("write")

    local has_keep_sorted = false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match("^%s*# keep%-sorted") then
        has_keep_sorted = true
        break
      end
    end

    if has_keep_sorted then
      local filepath = vim.fn.expand("%:p")
      local view = vim.fn.winsaveview()
      vim.fn.system({ "keep-sorted", filepath })
      vim.cmd("checktime") -- reload only if file changed
      vim.fn.winrestview(view)
    end
  end, { noremap = true, silent = true })
end

return M
