" Editing helpers for the src/entities/* files.

lua << EOF
-- Step the number under the cursor and rebuild.
local function step_number(direction)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- col is 0 based
  local from = 1

  while true do
    local first, last = line:find("%-?%d+%.?%d*", from)
    if not first then return false end

    if line:sub(first - 1, first - 1):lower() == "x" then from = last + 1 -- Don't touch 0xCD and friends.
    elseif last >= col + 1 then                                           -- Under the cursor, or the next one along.
      local text = line:sub(first, last)
      local point = text:find("%.")
      local decimals = point and (#text - point) or 0
      local within = col + 2 - first                                      -- 1 based index into text
      local step = 1
      if point and within > point then step = 10 ^ -(within - point) end

      local formatted = string.format("%." .. decimals .. "f", tonumber(text) + direction * step)
      vim.api.nvim_set_current_line(line:sub(1, first - 1) .. formatted .. line:sub(last + 1))

      -- Keep the cursor on the same place value so repeated presses keep the same step size.
      local moved = point and (first - 1) + formatted:find("%.") + (within - point) or first - 1 + within
      vim.api.nvim_win_set_cursor(0, {row, math.max(0, math.min(moved - 1, #vim.api.nvim_get_current_line() - 1))})
      return true
    else from = last + 1 end
  end
end

local function bump(direction, fallback)
  return function()
    if vim.bo.buftype ~= "" then return vim.cmd("normal! " .. fallback) end -- Quickfix, NERDTree, etc.
    for _ = 1, (vim.v.count > 0 and vim.v.count or 1) do
      if not step_number(direction) then return end                         -- No number here: nothing to build.
    end
    _G.build_project("minimal.")
  end
end

local function place_value(line, col)
  local from = 1
  while true do
    local first, last = line:find("%-?%d+%.?%d*", from)
    if not first then return 0.1 end                      -- Cursor isn't on a number: pick a sane default.
    if last >= col + 1 then
      local text, within = line:sub(first, last), col + 2 - first
      local point = text:find("%.")
      if point and within > point then return 10 ^ -(within - point) end
      return 1
    end
    from = last + 1
  end
end

local function adjust_field(line, field, delta, decimals)
  local pattern = "(%." .. field .. "%s*=%s*)(%-?%d+%.?%d*)(f?)"
  local prefix, value, suffix = line:match(pattern)
  if not value then                                       -- Field defaults to zero and isn't written out.
    if delta == 0 then return line end
    return line:gsub("(mat3%b())", function(call)
      local written = string.format("%." .. decimals .. "f", delta):gsub("(%..-)0+$", "%1"):gsub("%.$", ".0")
      return call:sub(1, -2) .. string.format(", .%s = %sf", field, written) .. ")"
    end, 1)
  end
  local places = math.max(decimals, #(value:match("%.(%d*)") or ""))
  local formatted = string.format("%." .. places .. "f", tonumber(value) + delta)
  formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", ".0")   -- 0.30 reads worse than 0.3.
  return line:gsub(pattern, prefix .. formatted .. suffix, 1)
end

local function field_under_cursor(line, col)
  local from = 1
  while true do
    local first, last, field = line:find("%.(%a+)%s*=%s*%-?%d+%.?%d*", from)
    if not first then return "tx" end
    if col + 1 >= first and col + 1 <= last then
      if field == "sx" or field == "sy" or field == "tx" or field == "ty" then return field end
      return "tx" -- .r, or anything else we don't resize by.
    end
    from = last + 1
  end
end

local function grow(direction)
  local line = vim.api.nvim_get_current_line()
  if not line:find("mat3%(") then return false end

  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local field = field_under_cursor(line, col)
  local axis = field:sub(2, 2)                        -- "x" or "y"
  local towards = field:sub(1, 1) == "s" and -1 or 1  -- The low edge moves the centre the other way.
  local step = place_value(line, col) * direction
  local decimals = math.max(0, math.ceil(-math.log(math.abs(step) / 2, 10)))

  line = adjust_field(line, "s" .. axis, step, decimals)
  line = adjust_field(line, "t" .. axis, step / 2 * towards, decimals)
  vim.api.nvim_set_current_line(line)
  return true
end

local function resize(direction)
  return function()
    if vim.bo.buftype ~= "" then return end
    for _ = 1, (vim.v.count > 0 and vim.v.count or 1) do
      if not grow(direction) then return end
    end
    _G.build_project("minimal.")
  end
end

_G.entity_grow = resize(1)
_G.entity_shrink = resize(-1)
_G.entity_bump_up = bump(1, "k")
_G.entity_bump_down = bump(-1, "j")
EOF
