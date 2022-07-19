local win_get_cursor = vim.api.nvim_win_get_cursor

local utils = {}

---Get 0-indexed cursor position for the window
---@param winnr integer? Window handle, or 0 for current window
---@return integer row
---@return integer col
function utils.get_cursor_0(winnr)
  winnr = winnr or 0
  local cursor = win_get_cursor(winnr) --[[@as {[1]: integer, [2]: integer}]]
  return cursor[1] - 1, cursor[2]
end

return utils
