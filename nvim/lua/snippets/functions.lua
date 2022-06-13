local functions = {}

---Returns SELECT_DEDENT
---@param _ any
---@param parent table The immediate parent of the functionNode
---@return string
function functions.select_dedent(_, parent)
  while parent do
    if parent.env then
      return parent.env.SELECT_DEDENT
    end
    parent = parent.parent
  end
  return ""
end

return functions
