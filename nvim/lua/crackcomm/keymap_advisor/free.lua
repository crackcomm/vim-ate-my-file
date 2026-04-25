-- Logic to find free/"convenient" keymaps.

local M = {}

-- QWERTY convenience scores. Higher is better.
local convenience_scores = {
  -- Home row
  f = 10,
  j = 10,
  d = 9,
  k = 9,
  s = 8,
  l = 8,
  a = 7,
  [";"] = 7,
  g = 6,
  h = 6,
  -- Top row
  r = 8,
  u = 8,
  e = 7,
  i = 7,
  w = 6,
  o = 6,
  q = 5,
  p = 5,
  t = 5,
  y = 5,
  -- Bottom row
  n = 7,
  m = 7,
  c = 6,
  v = 6,
  [","] = 5,
  ["."] = 5,
  b = 4,
  x = 4,
  z = 3,
  ["/"] = 3,
  -- Numbers
  ["1"] = 4,
  ["2"] = 4,
  ["3"] = 4,
  ["4"] = 5,
  ["5"] = 6,
  ["6"] = 6,
  ["7"] = 5,
  ["8"] = 4,
  ["9"] = 4,
  ["0"] = 3,
  -- Special chars - accessible without shift
  ["`"] = 2,
  ["-"] = 2,
  ["="] = 2,
  ["["] = 2,
  ["]"] = 2,
  ["\\"] = 2,
  ["'"] = 3,
  -- Space is special
  ["<Space>"] = 10,
  ["<Leader>"] = 10,
  ["<LocalLeader>"] = 9,
}

local function get_score(key)
  return convenience_scores[key] or convenience_scores[key:lower()] or 1
end

function M.get_free_keymaps()
  local all_maps = {}
  for _, mode in ipairs({ "n", "v", "x", "o" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      all_maps[map.lhs] = true
    end
  end

  local free_maps = {}
  local prefixes = {
    { key = "<Leader>", score = 10 },
    { key = "<LocalLeader>", score = 9 },
    { key = "g", score = 6 },
    { key = "z", score = 3 },
    { key = "[", score = 2 },
    { key = "]", score = 2 },
  }
  local chars = "abcdefghijklmnopqrstuvwxyz,./;'-=[]\\1234567890"

  for _, prefix in ipairs(prefixes) do
    for i = 1, #chars do
      local char = chars:sub(i, i)
      local keymap = prefix.key .. char
      if not all_maps[keymap] then
        local score = (prefix.score + get_score(char)) / 2
        table.insert(free_maps, { keymap = keymap, score = score })
      end
    end
  end

  -- Add single-character global maps
  for i = 1, #chars do
    local char = chars:sub(i, i)
    if not all_maps["g" .. char] then
      table.insert(free_maps, { keymap = "g" .. char, score = (get_score("g") + get_score(char)) / 2.5 })
    end
    if not all_maps["z" .. char] then
      table.insert(free_maps, { keymap = "z" .. char, score = (get_score("z") + get_score(char)) / 2.5 })
    end
  end

  table.sort(free_maps, function(a, b)
    return a.score > b.score
  end)

  return free_maps
end

return M
