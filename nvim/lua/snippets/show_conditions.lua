local show_conditions = {}

---A `show_condition` for LuaSnip matching beginning of the line.
---@param character_class? string A character class matching word trigger. Default: `%a`.
---@return fun(line_to_cursor: string): boolean
function show_conditions.is_line_beginning(character_class)
  character_class = character_class or "%a"
  return function(line_to_cursor)
    return line_to_cursor:find("^%s*" .. character_class .. "*$") ~= nil
  end
end

return show_conditions
