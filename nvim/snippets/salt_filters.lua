local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local cr = require("snippets.nodes").cr
local jinja_filter_snippets = require("snippets.jinja_utils").jinja_filter_snippets

-- SaltStack jinja filters
return jinja_filter_snippets({
  strftime = {
    dscr = "Converts date into a time-based string",
    nodes = c(1, { t(""), { t('"'), i(1, "format"), t('"') } }),
  },
  sequence = { dscr = "Ensure that parsed data is a sequence" },
})
