local autocmd = require("crackcomm.common.autocmd").autocmd
local telescope_mapper = require("crackcomm.telescope.handler")
local handlers = require("crackcomm.lsp.handlers")
local inlay_hints = require("crackcomm.lsp.inlay")
local capabilities = require("crackcomm.lsp.capabilities")

local autocmd_clear = vim.api.nvim_clear_autocmds
local augroup_highlight = vim.api.nvim_create_augroup("custom-lsp-references", { clear = true })

local keymap = require("crackcomm.common.keymap")
local buf_nnoremap = keymap.buf_nnoremap
local buf_inoremap = keymap.buf_inoremap
local buf_vnoremap = keymap.buf_vnoremap

local custom_init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

local custom_attach = function(client, bufnr)
  if client.name == "copilot" then
    return
  end

  keymap.nmap({ "<space>e", vim.diagnostic.open_float, "lsp:diagnostic" })
  buf_inoremap({ "<c-s>", vim.lsp.buf.signature_help, "lsp:signature_help" })

  buf_nnoremap({ "<space>cr", ":IncRename ", "lsp:rename" })
  buf_vnoremap({ "<space>ca", vim.lsp.buf.code_action, "lsp:code_action" })
  buf_nnoremap({ "<space>ca", vim.lsp.buf.code_action, "lsp:code_action" })

  buf_nnoremap({ "gd", handlers.definition, "lsp:definition" })
  buf_nnoremap({ "gD", vim.lsp.buf.declaration, "lsp:declaration" })
  buf_nnoremap({ "gT", vim.lsp.buf.type_definition, "lsp:type_definition" })
  buf_nnoremap({ "K", vim.lsp.buf.hover, "lsp:hover" })

  buf_nnoremap({ "<space>gI", handlers.implementation, "lsp:implementation" })
  buf_nnoremap({ "<space>rr", handlers.restart, "lsp:restart" })

  buf_nnoremap({ "<leader>cd", handlers.copy_all_diagnostics, "lsp:copy_all_diagnostics" })

  telescope_mapper("gr", "lsp_references", nil, true)
  telescope_mapper("gI", "lsp_implementations", nil, true)
  telescope_mapper("<space>ad", "diagnostics", { ignore_filename = true, bufnr }, true)
  telescope_mapper("<space>a", "diagnostics", { ignore_filename = true }, true)
  telescope_mapper("<space>ds", "lsp_document_symbols", { ignore_filename = true }, true)
  telescope_mapper("<space>ws", "lsp_workspace_symbols", { ignore_filename = true }, true)
  telescope_mapper("<space>wr", "lsp_dynamic_workspace_symbols", { ignore_filename = true }, true)

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    autocmd_clear({ group = augroup_highlight, buffer = bufnr })
    autocmd({
      "CursorHold",
      augroup_highlight,
      function()
        if capabilities.supports_document_highlight(bufnr) then
          vim.lsp.buf.document_highlight()
        end
      end,
      bufnr,
    })
    autocmd({ "CursorMoved", augroup_highlight, vim.lsp.buf.clear_references, bufnr })
  end

  if client.name == "ocamllsp" then
    client.server_capabilities.semanticTokensProvider = nil
  end

  inlay_hints(client, bufnr)
end

local updated_capabilities = vim.lsp.protocol.make_client_capabilities()

-- Completion configuration
vim.tbl_deep_extend("force", updated_capabilities, require("cmp_nvim_lsp").default_capabilities())
updated_capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

return {
  on_init = custom_init,
  on_attach = custom_attach,
  capabilities = updated_capabilities,
}
