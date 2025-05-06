local a = require("plenary.async")
local keymap = require("crackcomm.common.keymap")

local M = {}

function M.setup()
  keymap.nmap({
    "<leader>sp",
    function()
      R("crackcomm.jj.squash").squash_to_parent()
    end,
    desc = "[jj] Squash to parent",
  })
  keymap.nmap({
    "<leader>snp",
    function()
      R("crackcomm.jj.squash").squash_to_new_parent()
    end,
    desc = "[jj] Squash to new parent",
  })
  keymap.nmap({
    "<leader>ht",
    function()
      R("crackcomm.jj.hunks").toggle_hunk()
    end,
    desc = "[jj] Toggle hunk",
  })
  keymap.vmap({
    "<leader>ht",
    function()
      R("crackcomm.jj.hunks").add_selected_hunks()
    end,
    desc = "[jj] Toggle hunk",
  })
  keymap.nmap({
    "<leader>hc",
    function()
      R("crackcomm.jj.hunks").clear_marks()
    end,
    desc = "[jj] Clear all hunks",
  })
  keymap.nmap({
    "<leader>dj",
    function()
      R("crackcomm.jj.describe").generate_commit_message()
    end,
    desc = "[jj] Describe commit with LLM",
  })
  keymap.nmap({
    "<leader>jl",
    function()
      a.void(R("crackcomm.jj.log"))()
    end,
    desc = "[jj] Short log",
  })
end

return M
