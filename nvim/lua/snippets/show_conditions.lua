local show_conditions = {}

---A `show_condition` for LuaSnip matching beginning of the line.
---@param character_class? string A character class without surrounding `[]` matching word pattern. Default: `%w_`.
---@return fun(line_to_cursor: string): boolean
function show_conditions.is_line_beginning(character_class)
  character_class = character_class or "%w_"
  return function(line_to_cursor)
    return line_to_cursor:find("^%s*[" .. character_class .. "]*$") ~= nil
  end
end

---A `show_condition` for LuaSnip not matching beginning of the line.
---@param character_class? string A character class without surrounding `[]` matching word pattern. Default: `%w_`.
---@return fun(line_to_cursor: string): boolean
function show_conditions.is_not_line_beginning(character_class)
  character_class = character_class or "%w_"
  return function(line_to_cursor)
    return line_to_cursor:find(string.format("^%%s*[%s]+[^%s]", character_class, character_class))
      ~= nil
  end
end

return show_conditions
