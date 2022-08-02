local buf_get_option = vim.api.nvim_buf_get_option
local win_get_buf = vim.api.nvim_win_get_buf
local buf_get_text = vim.api.nvim_buf_get_text
local buf_get_offset = vim.api.nvim_buf_get_offset
local get_parser = vim.treesitter.get_parser
local get_string_parser = vim.treesitter.get_string_parser
local get_query = vim.treesitter.get_query
local get_node_text = vim.treesitter.get_node_text
local is_in_node_range = require("nvim-treesitter.ts_utils").is_in_node_range
local get_cursor_0 = require("utils").get_cursor_0

local utils = {}

---Returns cursor position relative to tree-sitter node
---@param node table
---@param row integer
---@param col integer
---@return integer row
---@return integer col
---@return integer byte_offset
local function get_cursor_relative_to_node(node, row, col)
  local start_row, start_col, start_byte = node:start() --[[@as integer, integer, integer]]
  if row < start_row or row == start_row and col < start_col then
    return 0, 0, 0
  elseif row == start_row then
    return 0, col - start_col, col - start_col
  else
    return row - start_row, col, buf_get_offset(0, row) - start_byte + col
  end
end

---Returns a list of captures `{capture_name, node}` at cursor
---@param query_name string The name of the query (i.e. "highlights")
---@param winnr? integer The window
---@param lang? string The filetype of a parser
---@param source_node? table The node for getting a range
---  (can be used to parse a part of the buffer as different filetype)
---@return {[1]: string, [2]:table, [3]: integer?}[] #`{capture_name, node, byte_offset_to_cursor?}[]`
function utils.get_captures_at_cursor(query_name, winnr, lang, source_node)
  winnr = winnr or 0
  ---@type integer | string
  local source
  source = win_get_buf(winnr) --[[@as integer]]
  lang = lang or buf_get_option(source, "filetype")
  local row, col, cursor_byte, parser
  row, col = get_cursor_0(winnr)
  if source_node then
    source = get_node_text(source_node, source) --[[@as string]]
    row, col, cursor_byte = get_cursor_relative_to_node(source_node, row, col)
    parser = get_string_parser(source, lang)
  else
    parser = get_parser(source, lang)
  end

  local captures = {}

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
  if not query then
    return captures
  end
  for id, node in query:iter_captures(root, source, row, row + 1) do
    if is_in_node_range(node, row, col - 1) then
      table.insert(captures, { query.captures[id], node, cursor_byte })
    end
  end
  return captures
end

---Returns the text from node start position to cursor position
---@param node table The node
---@param source string | integer | nil The window or string from which the node is extracted
---@param cursor_byte integer? Byte offset of the cursor position if source is a string
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
