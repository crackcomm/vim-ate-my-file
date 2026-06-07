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

RX = function(name)
  return setmetatable({}, {
    __index = function(_, key)
      return function(...)
        local args = { n = select("#", ...), ... }
        return function()
          return R(name)[key](unpack(args, 1, args.n))
        end
      end
    end,
    __call = function(_, ...)
      local args = { n = select("#", ...), ... }
      return function()
        return R(name)(unpack(args, 1, args.n))
      end
    end,
  })
end

--- @diagnostic disable-next-line: lowercase-global
errorf = function(msg, ...)
  error(string.format(msg, ...))
end
