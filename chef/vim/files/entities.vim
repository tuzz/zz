" Editing helpers for the src/entities/* files. The arrow keys in dap.vim call the entity_* functions at the bottom.

lua << EOF
-- Find the number under the cursor, or the next one along, skipping digits that are part of a name like mat3, light0 or 0xCD.
local function number_at_cursor(line, col)
  local from = 1
  while true do
    local first, last = line:find("%-?%d+%.?%d*", from)
    if not first then return nil end

    local before, after = line:sub(first - 1, first - 1), line:sub(last + 1, last + 1)
    local is_in_name = before:match("[%w_]") or (after:match("[%w_]") and after ~= "f") -- But allow the f in 1.5f.
    if not is_in_name and last >= col + 1 then return first, last end
    from = last + 1
  end
end

-- Return the value of the digit under the cursor to step by, e.g. 0.01 on the hundredths digit.
local function step_size_at_cursor(line, col)
  local first, last = number_at_cursor(line, col)
  if not first then return 0.1 end -- Not on a number, so default to 0.1.

  local text, within = line:sub(first, last), col + 2 - first
  local point = text:find("%.")
  if point and within > point then return 10 ^ -(within - point) end
  return 1
end

-- Change the number under the cursor by the value of the digit the cursor is on, e.g. by 0.1 on the tenths digit.
local function step_number_at_cursor(direction)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- col is 0 based
  local first, last = number_at_cursor(line, col)
  if not first then return false end

  local text = line:sub(first, last)
  local point = text:find("%.")
  local decimals = point and (#text - point) or 0
  local within = col + 2 - first -- Which character of the number the cursor is on, from 1.
  local step = step_size_at_cursor(line, col)

  local formatted = string.format("%." .. decimals .. "f", tonumber(text) + direction * step)
  vim.api.nvim_set_current_line(line:sub(1, first - 1) .. formatted .. line:sub(last + 1))

  -- Keep the cursor on the same digit so that pressing again steps by the same amount.
  local moved = point and (first - 1) + formatted:find("%.") + (within - point) or first - 1 + within
  vim.api.nvim_win_set_cursor(0, {row, math.max(0, math.min(moved - 1, #vim.api.nvim_get_current_line() - 1))})
  return true
end

-- Step the number under the cursor once, or [count] times, and then rebuild the game.
local function step_number_and_build(direction)
  for _ = 1, vim.v.count1 do
    if not step_number_at_cursor(direction) then return end -- No number here, so there's nothing to rebuild.
  end
  _G.build_project("minimal.")
end

-- Add delta to a field of the mat3(...) on this line, e.g. .sx, and add the field if it isn't written yet.
local function add_to_mat3_field(line, field, delta, decimals)
  local pattern = "(%." .. field .. "%s*=%s*)(%-?%d+%.?%d*)(f?)"
  local prefix, value, suffix = line:match(pattern)
  if not value then -- The field isn't written, so it's zero and we append it.
    if delta == 0 then return line end
    return line:gsub("(mat3%b())", function(call)
      local written = string.format("%." .. decimals .. "f", delta):gsub("(%..-)0+$", "%1"):gsub("%.$", ".0")
      return call:sub(1, -2) .. string.format(", .%s = %sf", field, written) .. ")"
    end, 1)
  end
  local places = math.max(decimals, #(value:match("%.(%d*)") or ""))
  local formatted = string.format("%." .. places .. "f", tonumber(value) + delta)
  formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", ".0") -- Drop trailing zeros, e.g. 0.30 becomes 0.3.
  return line:gsub(pattern, prefix .. formatted .. suffix, 1)
end

-- Return which mat3(...) field the cursor is on out of .sx, .sy, .tx and .ty, or .tx if it's on none of them.
local function mat3_field_at_cursor(line, col)
  local from = 1
  while true do
    local first, last, field = line:find("%.(%a+)%s*=%s*%-?%d+%.?%d*", from)
    if not first then return "tx" end
    if col + 1 >= first and col + 1 <= last then
      if field == "sx" or field == "sy" or field == "tx" or field == "ty" then return field end
      return "tx" -- e.g. .r, which resizing doesn't change.
    end
    from = last + 1
  end
end

-- Resize the mat3(...) on this line along the axis under the cursor, keeping one edge where it is.
local function resize_mat3_at_cursor(direction)
  local line = vim.api.nvim_get_current_line()
  if not line:find("mat3%(") then return false end

  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local field = mat3_field_at_cursor(line, col)
  local axis = field:sub(2, 2)                        -- "x" or "y"
  local towards = field:sub(1, 1) == "s" and -1 or 1  -- On .sx/.sy keep the right/top edge still, and on .tx/.ty the left/bottom edge.
  local step = step_size_at_cursor(line, col) * direction
  local decimals = math.max(0, math.ceil(-math.log(math.abs(step) / 2, 10))) -- Enough for half a step, since the centre moves by half.

  line = add_to_mat3_field(line, "s" .. axis, step, decimals)
  line = add_to_mat3_field(line, "t" .. axis, step / 2 * towards, decimals)
  vim.api.nvim_set_current_line(line)
  return true
end

-- Resize the mat3(...) under the cursor once, or [count] times, and then rebuild the game.
local function resize_mat3_and_build(direction)
  for _ = 1, vim.v.count1 do
    if not resize_mat3_at_cursor(direction) then return end
  end
  _G.build_project("minimal.")
end

_G.entity_increment_number = function() step_number_and_build(1) end
_G.entity_decrement_number = function() step_number_and_build(-1) end
_G.entity_grow = function() resize_mat3_and_build(1) end
_G.entity_shrink = function() resize_mat3_and_build(-1) end

-- Write the selected_location.txt which the game uses to move the camera to the selected entity.
vim.keymap.set("n", "<leader>e", function()
  local view = vim.fn.winsaveview()
  local found = vim.fn.search("entity_create(", "bcW") > 0
  if found then vim.cmd("keepjumps normal! f(%") end
  local location = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.winrestview(view)
  if not found then return end

  vim.fn.writefile({location}, "build/debug/selected_location.txt.tmp")
  vim.fn.rename("build/debug/selected_location.txt.tmp", "build/debug/selected_location.txt")
end)
EOF
