local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local r = require("luasnip.nodes.restoreNode").R
local cr = require("snippets.nodes").cr
local jinja_filter_snippets = require("snippets.jinja_utils").jinja_filter_snippets

-- SaltStack jinja tests
return jinja_filter_snippets({
  match = {
    dscr = "Tests that a string matches the regex",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "pattern"), t('"') }),
      { r(1, 1), t(", ignorecase=true") },
      { r(1, 1), t(", multiline=true") },
      { r(1, 1), t(", multiline=true, multiline=true") },
    }),
  },
})
