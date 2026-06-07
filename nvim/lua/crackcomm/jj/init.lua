local a = require("plenary.async")
local keymap = require("crackcomm.common.keymap")

local M = {}

function M.setup()
  keymap.nmap({
    "<leader>sp",
    RX("crackcomm.jj.squash").squash_to_parent(),
    desc = "[jj] Squash to parent",
  })
  keymap.nmap({
    "<leader>snp",
    RX("crackcomm.jj.squash").squash_to_new_parent(),
    desc = "[jj] Squash to new parent",
  })
  keymap.nmap({
    "<leader>ht",
    RX("crackcomm.jj.hunks").toggle_hunk(),
    desc = "[jj] Toggle hunk",
  })
  keymap.vmap({
    "<leader>ht",
    RX("crackcomm.jj.hunks").add_selected_hunks(),
    desc = "[jj] Toggle hunk",
  })
  keymap.nmap({
    "<leader>hc",
    RX("crackcomm.jj.hunks").clear_marks(),
    desc = "[jj] Clear all hunks",
  })
  keymap.nmap({
    "<leader>dj",
    RX("crackcomm.jj.describe").generate_commit_message(),
    desc = "[jj] Describe commit with LLM",
  })
  keymap.nmap({
    "<leader>jl",
    a.void(RX("crackcomm.jj.log")()),
    desc = "[jj] Short log",
  })
end

return M
