local M = {}

function M.suppress_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
  if #diagnostics == 0 then
    vim.notify("No diagnostics found on this line", vim.log.levels.WARN)
    return
  end

  -- Filter for diagnostics that have a code
  local candidates = {}
  for _, d in ipairs(diagnostics) do
    local code = d.code
    -- If code is not present, try to extract from message [code]
    if not code and d.message then
      code = d.message:match("%[(.-)%]$")
    end
    if code then
      d.code = code -- normalization
      table.insert(candidates, d)
    end
  end

  if #candidates == 0 then
    vim.notify("No diagnostics with codes found on this line", vim.log.levels.WARN)
    return
  end

  -- Find the diagnostic closest to the cursor
  table.sort(candidates, function(a, b)
    -- If cursor is inside diagnostic range, it's a high priority
    local a_inside = col >= a.col and col <= (a.end_col or a.col)
    local b_inside = col >= b.col and col <= (b.end_col or b.col)
    if a_inside ~= b_inside then
      return a_inside
    end
    -- Otherwise, closest by start column
    return math.abs(a.col - col) < math.abs(b.col - col)
  end)

  local diag = candidates[1]
  local code = diag.code
  if type(code) ~= "string" then
    code = tostring(code)
  end

  -- Special case for pointer arithmetic
  if code:match("pointer%-arithmetic$") then
    code = "*-pointer-arithmetic"
  end

  local prev_line_idx = line - 1
  local current_line_content = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
  local indent = current_line_content:match("^(%s*)")

  if prev_line_idx >= 0 then
    local prev_line_content = vim.api.nvim_buf_get_lines(bufnr, prev_line_idx, prev_line_idx + 1, false)[1]
    local existing_codes = prev_line_content:match("// NOLINTNEXTLINE%s*%((.*)%)")
    if existing_codes then
      -- Check if code already exists in the list
      local codes = vim.split(existing_codes, ",", { trimempty = true })
      local found = false
      for i, c in ipairs(codes) do
        codes[i] = vim.trim(c)
        if codes[i] == code then
          found = true
          break
        end
      end

      if not found then
        table.insert(codes, code)
        local prev_indent = prev_line_content:match("^(%s*)")
        local new_line = prev_indent .. "// NOLINTNEXTLINE(" .. table.concat(codes, ",") .. ")"
        vim.api.nvim_buf_set_lines(bufnr, prev_line_idx, prev_line_idx + 1, false, { new_line })
      else
        vim.notify("Diagnostic '" .. code .. "' already suppressed", vim.log.levels.INFO)
      end
      return
    elseif prev_line_content:match("// NOLINTNEXTLINE") then
      -- It's a NOLINTNEXTLINE without parens (suppresses everything)
      vim.notify("Line already suppressed by NOLINTNEXTLINE", vim.log.levels.INFO)
      return
    end
  end

  -- If we are here, we need to insert a new line
  local new_line = indent .. "// NOLINTNEXTLINE(" .. code .. ")"
  vim.api.nvim_buf_set_lines(bufnr, line, line, false, { new_line })
  -- Move cursor down to stay on the same code line
  vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, col })
end

return M
