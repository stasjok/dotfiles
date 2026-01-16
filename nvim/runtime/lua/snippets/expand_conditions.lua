local luasnip_expand_conditions = require("luasnip.extras.conditions.expand")

local expand_conditions = {}

expand_conditions.is_line_beginning = luasnip_expand_conditions.line_begin

---An `expand_condition` for LuaSnip matching if trigger is after a pattern
---@param pattern string A pattern for matching
---@return fun(line_to_cursor: string, matched_trigger: string): boolean
function expand_conditions.is_after(pattern)
  return function(line_to_cursor, matched_trigger)
    return line_to_cursor:sub(1, -(#matched_trigger + 1)):match(pattern .. "$")
  end
end

return expand_conditions
