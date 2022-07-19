local win_get_cursor = vim.api.nvim_win_get_cursor
local win_get_buf = vim.api.nvim_win_get_buf
local buf_get_text = vim.api.nvim_buf_get_text
local get_parser = vim.treesitter.get_parser
local get_query = vim.treesitter.get_query
local is_in_node_range = require("nvim-treesitter.ts_utils").is_in_node_range

local utils = {}

---Returns a list of captures `{capture_name, node}` at cursor
---@param winnr? integer Window number
---@param query_name? string The name of the query (i.e. "highlights")
---@param lang? string The filetype of a parser
---@return {[1]: string, [2]:table}[]
function utils.get_captures_at_cursor(winnr, query_name, lang)
  local captures = {}
  winnr = winnr or 0
  local bufnr = win_get_buf(winnr) --[[@as integer]]
  local cursor = win_get_cursor(winnr) --[[@as {[1]: integer, [2]: integer}]]
  local row, col = cursor[1] - 1, cursor[2]

  local parser = get_parser(bufnr, lang)
  if not parser then
    return captures
  end

  local root
  for _, tree in ipairs(parser:parse()) do
    root = tree:root()
    if root and is_in_node_range(root, row, col) then
      break
    end
  end
  if not root then
    return captures
  end

  local query = get_query(lang, query_name)
  for id, node in query:iter_captures(root, bufnr, row, row + 1) do
    if is_in_node_range(node, row, col) then
      table.insert(captures, { query.captures[id], node })
    end
  end
  return captures
end

---Returns the text from node start position to cursor position
---@param node table The node
---@param winnr integer Window number
---@return string
function utils.get_node_text_before_cursor(node, winnr)
  winnr = winnr or 0
  local bufnr = win_get_buf(winnr) --[[@as integer]]
  local cursor = win_get_cursor(winnr) --[[@as {[1]: integer, [2]: integer}]]
  local row, col = cursor[1] - 1, cursor[2]
  local start_row, start_col = node:start() --[[@as integer, integer, integer]]
  if row < start_row or row == start_row and col < start_col then
    return ""
  end
  local lines = buf_get_text(bufnr, start_row, start_col, row, col, {}) --[[@as table]]
  return table.concat(lines, "\n")
end

---Returns the text from node start position to provided cursor position
---@param node table The node
---@param lines string[] Source lines
---@param row integer Cursor row
---@param col integer Cursor column
---@return string
function utils.get_node_text_before_cursor_string(node, lines, row, col)
  local start_row, start_col = node:start()
  local result = vim.list_slice(lines, start_row + 1, row + 1)
  if #result == 0 then
    return ""
  elseif #result == 1 then
    return string.sub(result[1], start_col + 1, col)
  else
    result[1] = string.sub(result[1], start_col + 1)
    result[#result] = string.sub(result[#result], 1, col)
  end
  return table.concat(result, "\n")
end

return utils
