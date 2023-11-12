local log = require("plenary.log").new({
  plugin = "pah",
  level = "debug",
  use_console = true,
  info_level = 3,
})

local source = {}

---Invoke completion
function source:complete(params, callback)
  local name = vim.api.nvim_buf_get_name(params.context.bufnr)
  if not name or name == "" then
    callback({})
    return
  end

  local lines = vim.api.nvim_buf_get_lines(params.context.bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  log.info("test", {
    name = name,
    content = content,
    cursor = params.context.cursor,
  })

  callback({
    { label = "October" },
    { label = "Jerry!" },
    { label = "Tilde!" },
  })
end

local cmp = require("cmp")

if CRACKCOMM_TEST ~= nil then
  cmp.unregister_source(CRACKCOMM_TEST)
end

CRACKCOMM_TEST = cmp.register_source("crackcomm_test", source)
