if not pcall(require, "telescope") then
  return
end

TelescopeMapArgs = TelescopeMapArgs or {}

local map_tele = function(key, f, options, buffer)
  local map_key = vim.api.nvim_replace_termcodes(key .. f, true, true, true)

  TelescopeMapArgs[map_key] = options or {}

  local mode = "n"
  local rhs = string.format("<cmd>lua require('crackcomm.telescope')['%s'](TelescopeMapArgs['%s'])<CR>", f, map_key)

  local map_options = {
    desc = "telescope:" .. f,
    noremap = true,
    silent = true,
  }

  if not buffer then
    vim.keymap.set(mode, key, rhs, map_options)
  else
    map_options.buffer = buffer
    vim.keymap.set(mode, key, rhs, map_options)
  end
end

return map_tele
