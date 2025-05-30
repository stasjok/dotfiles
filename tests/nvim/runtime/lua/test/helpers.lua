local M = {}

-- For backward compatibility
M.expect = require("test.expect")
M.new_child = require("test.Child").new

---@class test.helpers.dedent.opts
---@field trim? boolean Trim last trailing newline. Default: `true`.

--- Remove common indent from a given string.
--- One trailing newline is trimmed by default.
--- Can be disabled with `opts.trim = false`.
--- Empty lines (lines containing only whitespaces) are ignored.
---@param str string Input string
---@param opts? test.helpers.dedent.opts Options
---@return string
function M.dedent(str, opts)
  opts = opts or {}
  local trim = vim.F.if_nil(opts.trim, true)

  -- Split input string
  local lines = vim.split(str, "\n", { plain = true })

  -- Trim last line
  if trim and lines[#lines]:find("^%s*$") then
    lines[#lines] = nil
  end

  -- Find minimal indent
  local minimal_indent = math.huge
  for _, s in ipairs(lines) do
    local _, indent = s:find("^%s*") --[[@as integer Always matches]]
    if indent ~= #s then
      if indent == 0 then
        -- No indent, return early
        return trim and table.concat(lines, "\n") or str
      elseif indent < minimal_indent then
        minimal_indent = indent
      end
    end
  end

  return vim
    .iter(lines)
    :map(function(s)
      return s:sub(minimal_indent + 1)
    end)
    :join("\n")
end

--- Wrap every value in the table into another table,
--- e.g. `{1, 2}` -> `{{1}, {2}}`.
---@param t table
---@return table
function M.wrap_values(t)
  return vim
    .iter(t)
    :map(function(...)
      return { ... }
    end)
    :totable()
end

return M
