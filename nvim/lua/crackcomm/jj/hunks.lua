local gs = require("gitsigns")
local jj = require("crackcomm.jj.common")

local ns = vim.api.nvim_create_namespace("jj_squash")

-- TODO: move
vim.api.nvim_set_hl(0, "JJHunkDeleted", {
  underline = true,
  sp = "#f85149",
  cterm = { underline = true },
})

local function hunk_range(h)
  if h.type == "delete" then
    -- return h.removed.start, h.removed.start + h.removed.count - 1
    return h.added.start, h.removed.start - 1
  else
    return h.added.start, h.added.start + h.added.count - 1
  end
end

local function hunk_style(h)
  if h.type == "delete" then
    return "JJHunkDeleted"
  elseif h.type == "add" then
    return "DiffAdd"
  elseif h.type == "change" then
    return "DiffChange"
  end
end

local M = {}

--- Toggles the hunk at the current cursor position.
function M.toggle_hunk()
  local buf = vim.api.nvim_get_current_buf()
  local hunks = gs.get_hunks(buf)
  if not hunks then
    return
  end

  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
  local cursor = vim.api.nvim_win_get_cursor(0)[1]

  for _, h in ipairs(hunks) do
    local s, e = hunk_range(h)
    if cursor >= s and cursor <= e then
      -- Look for an extmark with matching start and end line
      for _, mark in ipairs(marks) do
        local id, mark_row, _, d = unpack(mark)
        if d and d.end_row == e and mark_row == s - 1 then
          vim.api.nvim_buf_del_extmark(buf, ns, id)
          return
        end
      end

      vim.api.nvim_buf_set_extmark(buf, ns, s - 1, 0, {
        end_line = e,
        hl_group = hunk_style(h),
        hl_eol = true,
      })
      return
    end
  end
end

--- Removes degenerate marks (marked but later deleted) from all buffers.
local function clear_degenerate_marks()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
    for _, mark in ipairs(marks) do
      local id, row, _, details = unpack(mark)
      if details.end_row == row then
        vim.api.nvim_buf_del_extmark(bufnr, ns, id)
        print(("Removed degenerate mark %d-%d"):format(row + 1, details.end_row))
      end
    end
  end
end

--- Clears all marks in the specified buffer or all buffers if no buffer is specified.
--- @param bufnr number? The buffer number to clear marks from. If nil, clears marks from all buffers.
function M.clear_marks(bufnr)
  if bufnr then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- clear all extmarks
  else
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      M.clear_marks(b)
    end
  end
end

--- Returns all selected hunks in the buffer.
--- If `invert` is true returns the inverse of the selected hunks.
--- @param bufnr number The buffer number to check.
--- @param invert boolean? If true, return the hunks that are not selected.
function M.selected_hunks(bufnr, invert)
  local hunks = gs.get_hunks(bufnr) or {}
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
  if #marks == 0 then
    return {}
  end

  -- Build a set of selected hunks for fast lookup
  local selected = {}
  for _, hunk in ipairs(hunks) do
    local hstart, hend = hunk_range(hunk)
    for _, mark in ipairs(marks) do
      local _, row, _, details = unpack(mark)
      if details.end_row and row == hstart - 1 and details.end_row == hend then
        selected[hunk] = true
        break
      end
    end
  end

  local result = {}
  for _, hunk in ipairs(hunks) do
    if (not invert and selected[hunk]) or (invert and not selected[hunk]) then
      table.insert(result, hunk)
    end
  end
  return result
end

--- Checks if any buffer has hunks.
--- @param invert boolean? If true, check for the inverse of the hunks.
--- @param bufnr number? The buffer number to check. If nil, checks all buffers.
--- @return boolean true if any buffer has hunks, false otherwise
function M.has_hunks(invert, bufnr)
  if bufnr then
    return #M.selected_hunks(bufnr, not invert) > 0
  end
  clear_degenerate_marks()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if M.has_hunks(invert, b) then
      return true
    end
  end
  return false
end

--- Sets all visually selected hunks as extmarks.
function M.add_selected_hunks()
  local buf = vim.api.nvim_get_current_buf()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  if s > e then
    s, e = e, s
  end

  local hunks = gs.get_hunks(buf)
  if not hunks then
    return
  end

  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })

  for _, hunk in ipairs(hunks) do
    local hstart, hend = hunk_range(hunk)
    if hend >= s and hstart <= e then
      local exists = false
      for _, mark in ipairs(marks) do
        local _, row, _, details = unpack(mark)
        if details.end_row and row == hstart - 1 and details.end_row == hend then
          exists = true
          break
        end
      end
      if not exists then
        vim.api.nvim_buf_set_extmark(buf, ns, hstart - 1, 0, {
          end_line = hend,
          hl_group = "DiffChange",
          hl_eol = true,
        })
      end
    end
  end
end

--- Constructs a patch string from the given hunks.
--- NOTE: this is a fixed gitsigns create_patch function
--- @param relpath string The relative path of the file.
--- @param hunks table The list of hunks to include in the patch.
--- @param mode_bits string? The mode bits for the file (default: "100644").
--- @param invert boolean? If true, invert the hunks (default: false).
local function construct_patch(relpath, hunks, mode_bits, invert)
  invert = invert or false
  mode_bits = mode_bits or "100644"

  local results = {
    string.format("diff --git a/%s b/%s", relpath, relpath),
    "index 000001..000002 " .. mode_bits,
    "--- a/" .. relpath,
    "+++ b/" .. relpath,
  }

  local offset = 0

  for _, process_hunk in ipairs(hunks) do
    local removed_start = process_hunk.removed.start
    local added_start = process_hunk.added.start
    local pre_count = process_hunk.removed.count
    local now_count = process_hunk.added.count

    -- Git expects one-based line numbers, and special casing for 'add'
    if process_hunk.type == "add" then
      removed_start = removed_start + 1
    end

    local pre_lines = process_hunk.removed.lines
    local now_lines = process_hunk.added.lines

    if invert then
      removed_start, added_start = added_start, removed_start
      pre_count, now_count = now_count, pre_count
      pre_lines, now_lines = now_lines, pre_lines
    end

    local old_start = removed_start
    local new_start = added_start + offset

    table.insert(results, string.format("@@ -%d,%d +%d,%d @@", old_start, pre_count, new_start, now_count))

    for _, l in ipairs(pre_lines) do
      results[#results + 1] = "-" .. l
    end

    if process_hunk.removed.no_nl_at_eof then
      results[#results + 1] = "\\ No newline at end of file"
    end

    for _, l in ipairs(now_lines) do
      results[#results + 1] = "+" .. l
    end

    if process_hunk.added.no_nl_at_eof then
      results[#results + 1] = "\\ No newline at end of file"
    end

    offset = offset + (now_count - pre_count)
  end

  return results
end

--- Creates a patch string from the given buffer and hunks.
--- @param buf number The buffer number.
--- @param hunks table The list of hunks to include in the patch.
--- @param invert boolean? If true, invert the hunks (default: false).
--- @return table The patch string as a table of lines.
local function create_patch(buf, hunks, invert)
  local rel = jj.buf_rel_path(buf)
  local patch = construct_patch(rel, hunks, "100644", invert)
  patch[#patch + 1] = ""
  return patch
end

--- Writes contents to a file, creating the directory if it doesn't exist.
--- @param fpath string The file path to write to.
--- @param content string|table The content to write to the file.
local function write_file(fpath, content)
  vim.fn.mkdir(vim.fs.dirname(fpath), "p")
  vim.fn.writefile(content, fpath)
end

--- Writes patches for all buffers with hunks to the specified directory.
--- If no directory is specified, a temporary directory is created.
--- @param dst string? The destination directory to write patches to.
--- @param invert boolean? If true, write the inverse of the hunks (default: false).
--- @return string The destination directory where patches were written.
function M.write_patches(dst, invert)
  dst = dst or vim.fn.tempname() .. "/patch"
  vim.fn.mkdir(dst, "p")

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if M.has_hunks(invert, bufnr) then
      local hunks = M.selected_hunks(bufnr, invert)
      local patch = create_patch(bufnr, hunks, invert)
      write_file(("%s/%s.patch"):format(dst, jj.buf_rel_path(bufnr)), patch)
    end
  end

  return dst
end

return M
