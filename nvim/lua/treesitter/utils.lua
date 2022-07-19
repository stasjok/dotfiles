local win_get_buf = vim.api.nvim_win_get_buf
local buf_get_text = vim.api.nvim_buf_get_text
local get_parser = vim.treesitter.get_parser
local get_query = vim.treesitter.get_query
local is_in_node_range = require("nvim-treesitter.ts_utils").is_in_node_range
local get_cursor_0 = require("utils").get_cursor_0

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
  local row, col = get_cursor_0(winnr)

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
---@param source string | integer | nil The window or string from which the node is extracted
---@param cursor_byte integer? Byte offset of the cursor position is source is a string
---@return string
function utils.get_node_text_before_cursor(node, source, cursor_byte)
  local start_row, start_col, start_byte = node:start() --[[@as integer, integer, integer]]
  if type(source) == "string" then
    return source:sub(start_byte + 1, cursor_byte)
  else
    local winnr = source or 0
    local bufnr = win_get_buf(winnr) --[[@as integer]]
    local row, col = get_cursor_0(winnr)
    if row < start_row or row == start_row and col < start_col then
      return ""
    end
    local lines = buf_get_text(bufnr, start_row, start_col, row, col, {}) --[[@as table]]
    return table.concat(lines, "\n")
  end
end

return utils
