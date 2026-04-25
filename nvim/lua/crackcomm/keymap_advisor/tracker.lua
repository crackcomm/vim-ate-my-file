-- Keymap usage tracker with monkey-patching.
--

local persistence = R("crackcomm.workspace.persistence")
local DATA_KEY = "keymap_advisor_counts"

local M = {}

M.__counts = {}

function M.load_counts()
  return persistence.load(DATA_KEY) or { global = {} }
end

local function deep_sum(a, b)
  local result = vim.deepcopy(a)
  for key, value in pairs(b) do
    if type(value) == "table" and type(result[key]) == "table" then
      result[key] = deep_sum(result[key], value)
    else
      result[key] = (result[key] or 0) + value
    end
  end
  return result
end

function M.get_counts()
  local loaded_counts = M.load_counts()
  return deep_sum(M.__counts, loaded_counts)
end

function M.save_counts()
  -- Load existing counts to ensure we don't overwrite any changes made during the session.
  local existing_counts = persistence.load(DATA_KEY) or { global = {} }

  -- Sum the current session's counts with the existing counts.
  local merged_counts = deep_sum(M.__counts, existing_counts)

  persistence.save(DATA_KEY, merged_counts)
end

function M.increment_usage(mode, lhs)
  -- Increment global stats
  M.__counts.global = M.__counts.global or {}
  local global_modestore = M.__counts.global[mode] or {}
  global_modestore[lhs] = (global_modestore[lhs] or 0) + 1
  M.__counts.global[mode] = global_modestore
end

local original_nvim_set_keymap = vim.api.nvim_set_keymap

function M.setup()
  -- Prevent double-patching
  if vim.api.nvim_set_keymap ~= original_nvim_set_keymap then
    return
  end

  --- @diagnostic disable-next-line: duplicate-set-field
  vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts)
    opts = opts or {}
    -- Make a deep copy to avoid modifying the original opts table passed by the user.
    local new_opts = vim.deepcopy(opts)

    local original_rhs = rhs
    local original_callback = new_opts.callback

    new_opts.callback = function()
      M.increment_usage(mode, lhs)
      if original_callback then
        original_callback()
      elseif type(original_rhs) == "string" and original_rhs ~= "" then
        local command = vim.api.nvim_replace_termcodes(original_rhs, true, false, true)
        vim.api.nvim_feedkeys(command, "m", true)
      end
    end

    -- The 'rhs' is ignored if 'callback' is set, so we can pass the original.
    return original_nvim_set_keymap(mode, lhs, rhs, new_opts)
  end

  -- Save the counts when Neovim is about to exit.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = function()
      M.save_counts()
    end,
  })
end

return M
