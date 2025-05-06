local nmap = require("crackcomm.common.keymap").nmap
local vmap = require("crackcomm.common.keymap").vmap

local builtin = require("telescope.builtin")
local custom = require("crackcomm.telescope.custom")

-- telescope builtins
nmap({ "<space>tt", builtin.builtin, { silent = true, desc = "telescope: [t]elescope" } })
nmap({ "<space>tr", builtin.resume, { silent = true, desc = "telescope: [r]esume" } })

-- [h]ome
nmap({
  "<space>hf",
  function()
    custom.browse_files({
      path = vim.fn.expand("~/x"),
      depth = 1,
      hide_parent_dir = true,
      initial_mode = "normal",
    })
  end,
  "telescope: [h]ome [f]iles",
})

-- [w]orkspace (cwd)
nmap({ "<space>wf", builtin.find_files, "telescope: [w]orkspace [f]iles" })
nmap({ "<space>wg", builtin.live_grep, "telescope: [w]orkspace [g]rep" })
nmap({
  "<space>wd",
  function()
    custom.browse_files({
      depth = 1,
      files = true,
    })
  end,
  "telescope: [w]orkspace [d]irectories",
})

-- [b]uffers
nmap({
  "<space>bg",
  function()
    builtin.current_buffer_fuzzy_find({ reverse = false })
  end,
  "telescope: [b]uffer [g]rep",
})
nmap({
  "<space>bb",
  function()
    builtin.buffers({ initial_mode = "normal" })
  end,
  "telescope: [b]uffers",
})

-- current [f]ile
nmap({
  "<space>fg",
  function()
    builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
  end,
  "telescope: current [f]ile directory [g]rep",
})
nmap({
  "<space>ff",
  function()
    custom.browse_files({
      path = vim.fn.expand("%:p:h"),
      prompt_path = true,
    })
  end,
  "telescope: current [f]ile directory [f]ile browser",
})

nmap({ "<space>of", builtin.oldfiles, "telescope: [o]ld [f]iles" })

-- [g]it
nmap({ "<space>gs", builtin.git_status, "telescope: [g]it [s]tatus" })
nmap({ "<space>gf", builtin.git_files, "telescope: [g]it [f]iles" })
nmap({ "<space>gl", builtin.git_commits, "telescope: [g]it [l]og" })
nmap({ "<space>gc", builtin.git_bcommits, "telescope: [g]it [c]ommits" })
vmap({ "<space>gc", builtin.git_bcommits_range, "telescope: [g]it [c]ommits" })

-- [f][r]ecency
nmap({ "<space>fr", custom.frecency, "telescope: [f]recency" })
