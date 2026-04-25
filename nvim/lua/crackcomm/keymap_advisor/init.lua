-- Main setup for the keymap_advisor plugin.
-- This will be responsible for setting up user-facing commands and keymaps.

local M = {}

function M.setup()
  local keymap = require("crackcomm.common.keymap")
  local telescope_actions = require("crackcomm.keymap_advisor.telescope")

  keymap.nmap({
    "<leader>?",
    telescope_actions.find_free_keymaps,
    { desc = "[?] Find Free Keymaps" },
  })
  keymap.nmap({
    "<leader>kh",
    telescope_actions.show_keymap_usage,
    { desc = "[K]eymap [H]eatmap" },
  })
end

return M
