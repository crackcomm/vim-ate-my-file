local func = {}

func.autocmd = function(args)
  local event = args[1]
  local group = args[2]
  local callback = args[3]
  local buffer = args[4]

  vim.api.nvim_create_autocmd(event, {
    group = group,
    buffer = buffer,
    callback = function()
      callback()
    end,
    once = args.once,
  })
end

return func
