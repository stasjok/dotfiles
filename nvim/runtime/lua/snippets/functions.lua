local functions = {}

---Returns SELECT_DEDENT
---@param _ any
---@param parent table The immediate parent of the functionNode
---@return string
function functions.select_dedent(_, parent)
  while not parent.env do
    parent = parent.parent
  end
  return parent.env.SELECT_DEDENT
end

return functions
