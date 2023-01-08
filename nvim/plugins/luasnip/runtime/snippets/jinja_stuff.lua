local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local r = require("luasnip.nodes.restoreNode").R
local cr = require("snippets.nodes").cr

return {
  s({ trig = "if", dscr = "Inline if expression" }, {
    cr(1, {
      {
        r(1, 1, { i(2, "if_true"), t(" if "), i(1, "condition") }),
        t(" else "),
        i(2, "if_false"),
      },
      r(1, 1),
    }),
  }),
}
