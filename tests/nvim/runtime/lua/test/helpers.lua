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

  -- Find minimal indent
  local minimal_indent = math.huge
  for s in vim.gsplit(str, "\n", { plain = true, trimempty = true }) do
    if s ~= "" then
      local _, indent = s:find("^%s*")
      if indent == 0 then
        -- No indent, return early
        return str:sub(-1) == "\n" and trim and str:sub(1, -2) or str
      elseif indent and indent < minimal_indent and indent ~= #s then
        minimal_indent = indent
      end
    end
  end

  local out = vim
    .iter(vim.gsplit(str, "\n", { plain = true }))
    :map(function(s)
      return s:sub(minimal_indent + 1)
    end)
    :join("\n")
  return out:sub(-1) == "\n" and trim and out:sub(1, -2) or out
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
