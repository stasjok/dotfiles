local c = require("luasnip.nodes.choiceNode").C

local nodes = {}

function nodes.cr(pos, choices)
  return c(pos, choices, { restore_cursor = true })
end

return nodes
