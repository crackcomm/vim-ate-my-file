local log = require("crackcomm.log")

local M = {}

local function escape_pattern(text)
  return text:gsub("([^%w])", "%%%1")
end

M.debug_binary = function(filename)
  -- Get current permissions
  local permissions = vim.fn.getfperm(filename)
  if not permissions then
    log.error("Could not get file permissions for: " .. filename)
    return
  end

  -- Check if the file is write-protected (read-only)
  if permissions:sub(2, 2) == "-" then
    -- Temporarily change the file to writable
    os.execute("chmod +w " .. filename)
  end

  -- Read the file
  local file = io.open(filename, "r")
  if not file then
    log.error("Could not open file: " .. filename)
    return
  end
  local content = file:read("*all")
  file:close()

  -- Define the old and new function strings
  local old_function = [[  os.execv(python_program, [python_program, main_filename] + args)]]
  old_function = escape_pattern(old_function)

  local new_function = [[
  DEBUG_ARGS = ["-m", "debugpy", "--listen", "127.0.0.1:5678", "--wait-for-client"]
  os.execv(python_program, [python_program] + DEBUG_ARGS + [main_filename] + args)
]]

  -- Replace the old function with the new function
  local new_content = content:gsub(old_function, new_function)

  -- Write back to the file
  file = io.open(filename, "w")
  if not file then
    log.error("Could not open file for writing: " .. filename)
    return
  end
  file:write(new_content)
  file:close()

  return true
end

return M
