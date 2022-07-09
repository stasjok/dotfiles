local s = require("luasnip.nodes.snippet").S
local i = require("luasnip.nodes.insertNode").I
local jinja_nodes_for_filter = require("snippets.jinja_utils").jinja_nodes_for_filter

local snippets = {}

-- Jinja tests
for test, nodes in pairs({
  boolean = false,
  callable = false,
  defined = false,
  divisibleby = i(1, "num"),
  eq = true,
  equalto = true,
  escaped = false,
  even = false,
  ["false"] = false,
  filter = false,
  float = false,
  ge = true,
  gt = true,
  greaterthan = true,
  ["in"] = true,
  integer = false,
  iterable = false,
  le = true,
  lower = false,
  lt = true,
  lessthan = true,
  mapping = false,
  ne = false,
  none = false,
  number = false,
  odd = false,
  sameas = true,
  sequence = false,
  string = false,
  test = false,
  ["true"] = false,
  undefined = false,
  upper = false,
}) do
  nodes = jinja_nodes_for_filter(test, nodes)
  table.insert(snippets, s({ trig = test, dscr = "`" .. test .. "` test" }, nodes))
end

return snippets
