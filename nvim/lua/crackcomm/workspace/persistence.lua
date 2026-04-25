-- Simple persistence layer for crackcomm modules using plenary.
local M = {}

local plenary_path = require("plenary.path")

local function get_storage_path()
  return plenary_path:new(vim.fn.stdpath("data"), "crackcomm_workspace")
end

local function get_file_for_key(key)
  local storage_path = get_storage_path()
  return plenary_path:new(storage_path, key .. ".json")
end

---Saves a Lua table to a JSON file.
---@param key string The unique key for the data, used as the filename.
---@param data table The Lua table to save.
function M.save(key, data)
  local file_path = get_file_for_key(key)
  local storage_path = get_storage_path()

  local json_data = vim.json.encode(data)

  -- pcall(function()
  if not storage_path:exists() then
    storage_path:mkdir({ parents = true })
  end

  file_path:write(json_data, "w")
  -- end)
end

---Loads a Lua table from a JSON file.
---@param key string The key for the data to load.
---@return table|nil The loaded Lua table, or nil if not found or on error.
function M.load(key)
  local file_path = get_file_for_key(key)
  if not file_path:exists() then
    return nil
  end

  local content = file_path:read()
  if content == nil or content == "" then
    return nil
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Error decoding persistence file: " .. tostring(file_path), vim.log.levels.ERROR)
    return nil
  end
  return data
end

return M
