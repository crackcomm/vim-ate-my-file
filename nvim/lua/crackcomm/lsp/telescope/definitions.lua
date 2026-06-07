local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local M = {}

M.default_opts = {
  sorting_strategy = "ascending",
  ignore_filename = false,
  preview_cutoff = 0,
}

M.pick = function(title, raw, opts)
  opts = vim.tbl_extend("keep", opts or {}, M.default_opts)

  -- detect raw LSP-response shape (per-client errors/results)
  local is_raw = false
  for _, v in pairs(raw) do
    if type(v) == "table" and (v.result ~= nil or v.error ~= nil or v.err ~= nil) then
      is_raw = true
      break
    end
  end

  local items = {}
  if is_raw then
    -- convert results_per_client → quickfix entries
    for client_id, res in pairs(raw) do
      local err = res.error or res.err
      local result = res.result
      if err then
        -- you could collect errors[client_id] = err if you wish
      elseif result ~= nil then
        local locs = {}
        if not vim.islist(result) then
          table.insert(locs, result)
        else
          vim.list_extend(locs, result)
        end
        local enc = vim.lsp.get_client_by_id(client_id).offset_encoding
        vim.list_extend(items, vim.lsp.util.locations_to_items(locs, enc))
      end
    end
  else
    -- assume already quickfix-style entries
    items = raw
  end

  pickers
    .new(opts, {
      prompt_title = title,
      finder = finders.new_table({
        results = items,
        entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
      }),
      previewer = conf.qflist_previewer(opts),
      sorter = conf.generic_sorter(opts),
      push_cursor_on_edit = true,
      push_tagstack_on_edit = true,
    })
    :find()
end

return M
