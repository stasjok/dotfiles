local M = {}

-- For backward compatibility
M.expect = require("test.expect")
M.new_child = require("test.Child").new

--- Remove common indent from a given string
---@param str string
---@return string
function M.dedent(str)
  -- Find minimal indent
  local minimal_indent = math.huge
  for s in vim.gsplit(str, "\n", { plain = true, trimempty = true }) do
    if s ~= "" then
      local _, indent = s:find("^%s*")
      if indent == 0 then
        -- No indent, return early
        return str
      elseif indent and indent < minimal_indent then
        minimal_indent = indent
      end
    end
  end

  return vim
    .iter(vim.gsplit(str, "\n", { plain = true }))
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
