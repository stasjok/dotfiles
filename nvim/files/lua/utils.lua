local win_get_cursor = vim.api.nvim_win_get_cursor
local api = vim.api

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

---Create or get an autocommand group
---@param name string The name of the group
---@param opts? {clear: boolean?, buffer: integer?} Parameters.
---@return integer #ID of the created group
function utils.create_augroup(name, opts)
  opts = opts or {}
  local clear = vim.F.if_nil(opts.clear, true) --[[@as boolean]]
  local buffer = opts.buffer
  local augroup = api.nvim_create_augroup(name, { clear = false })
  if clear then
    api.nvim_clear_autocmds({ group = augroup, buffer = buffer })
  end
  return augroup
end

return utils
