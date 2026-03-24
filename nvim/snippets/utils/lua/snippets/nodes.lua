local nodes = {}

function nodes.cr(pos, choices, opts)
  return require("luasnip.nodes.choiceNode").C(
    pos,
    choices,
    vim.tbl_extend("keep", { restore_cursor = true }, opts or {})
  )
end

---Wrap nodes in snippetNode and set position
---@param pos number SnippetNode's position
---@param nodes table Nodes to wrap
---@param copy boolean? Return deepcopy of the snippetNode, default: `false`
---@return table
---@diagnostic disable-next-line: redefined-local
function nodes.wrapped_nodes(pos, nodes, copy)
  local wrapped = require("luasnip.nodes.snippet").wrap_nodes_in_snippetNode(nodes)
  wrapped.pos = pos
  return copy and wrapped:copy() or wrapped
end

return nodes
