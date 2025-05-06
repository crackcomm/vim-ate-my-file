local _require = require

P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return _require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return _require(name)
end

--- @diagnostic disable-next-line: lowercase-global
errorf = function(msg, ...)
  error(string.format(msg, ...))
end
