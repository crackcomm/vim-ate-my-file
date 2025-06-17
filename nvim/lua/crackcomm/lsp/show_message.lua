local protocol = require("vim.lsp.protocol")

local message_display = {
  bufnr = nil,
  win_id = nil,
  border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
}

--- @return number
local function get_bufnr()
  if not message_display.bufnr or not vim.api.nvim_buf_is_valid(message_display.bufnr) then
    message_display.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[message_display.bufnr].filetype = "log" -- for syntax highlighting if any
  end
  return message_display.bufnr
end

local function win_is_valid()
  return message_display.win_id and vim.api.nvim_win_is_valid(message_display.win_id)
end

local function create_float_window(messages_lines)
  local current_bufnr = get_bufnr()
  if win_is_valid() then
    vim.api.nvim_win_close(message_display.win_id, true)
  end

  local num_lines = #messages_lines
  local max_width = 0
  for _, line in ipairs(messages_lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  local ui = vim.api.nvim_list_uis()[1]
  local editor_height = ui.height
  local editor_width = ui.width

  local win_height = math.min(10, num_lines) -- Max 10 lines or less
  local win_width = math.min(80, max_width + 4) -- Max 80 cols or less, + padding

  message_display.win_id = vim.api.nvim_open_win(current_bufnr, false, {
    relative = "editor",
    style = "minimal",
    border = message_display.border_chars, -- or "rounded"
    height = win_height,
    width = win_width,
    row = math.floor((editor_height - win_height) / 2), -- Centered vertically
    col = math.floor((editor_width - win_width) / 2), -- Centered horizontally
    focusable = false, -- User cannot interact with it
    noautocmd = true,
  })

  vim.wo[message_display.win_id].winhighlight = "Normal:FloatWindow,FloatBorder:FloatBorder"
end

-- TODO: map this to a keybind :)
function LspShowMessageBuffer()
  vim.cmd([[new]])
  vim.cmd([[buffer ]] .. message_display.bufnr)
end

return function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local client_name = client and client.name or string.format("id=%d", ctx.client_id)

  local display_messages = {}

  if not client then
    error(string.format("[%s] client has shut down after sending the message", client_name))
  end

  if result.type == protocol.MessageType.Error then
    error(string.format("[%s] %s", client_name, result.message))
  else
    local type_name = protocol.MessageType[result.type]
    table.insert(display_messages, string.format("[%s] %s:", client_name, type_name))
    for _, text in ipairs(vim.split(result.message, "\n")) do
      table.insert(display_messages, "  " .. text .. "  ")
    end
  end

  local current_bufnr = get_bufnr()
  vim.api.nvim_buf_set_option(current_bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(current_bufnr, 0, -1, false, display_messages)
  vim.api.nvim_buf_set_option(current_bufnr, "modifiable", false)

  create_float_window(display_messages) -- Show the latest message or a snippet

  if win_is_valid() then
    vim.defer_fn(function()
      if win_is_valid() then
        vim.api.nvim_win_close(message_display.win_id, true)
        message_display.win_id = nil
      end
    end, 3500) -- Increased timeout slightly
  end

  return result
end
