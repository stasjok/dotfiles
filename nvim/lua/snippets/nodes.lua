local c = require("luasnip.nodes.choiceNode").C
local wrap_nodes_in_snippetNode = require("luasnip.nodes.snippet").wrap_nodes_in_snippetNode

local nodes = {}

function nodes.cr(pos, choices)
  return c(pos, choices, { restore_cursor = true })
end

---Wrap nodes in snippetNode and set position
---@param pos number SnippetNode's position
---@param nodes table Nodes to wrap
---@param copy boolean? Return deepcopy of the snippetNode, default: `false`
---@return table
---@diagnostic disable-next-line: redefined-local
function nodes.wrapped_nodes(pos, nodes, copy)
  local wrapped = wrap_nodes_in_snippetNode(nodes)
  wrapped.pos = pos
  return copy and wrapped:copy() or wrapped
end

return nodes
