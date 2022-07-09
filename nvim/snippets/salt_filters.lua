local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local cr = require("snippets.nodes").cr
local jinja_nodes_for_filter = require("snippets.jinja_utils").jinja_nodes_for_filter

local snippets = {}

-- SaltStack jinja filters
for filter, nodes in pairs({
  strftime = c(1, { t(""), { t('"'), i(1, "format"), t('"') } }),
  sequence = false,
}) do
  nodes = jinja_nodes_for_filter(filter, nodes)
  table.insert(snippets, s({ trig = filter, dscr = "`" .. filter .. "` filter" }, nodes))
end

return snippets
