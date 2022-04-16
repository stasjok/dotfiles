local s = require("luasnip.nodes.snippet").S
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local fmt = require("luasnip.extras.fmt").fmt

local function cr(pos, choices)
  return c(pos, choices, { restore_cursor = true })
end

local function fmte(str, nodes)
  return fmt(str, nodes, { trim_empty = false, dedent = false })
end

return {
  -- attr = value;
  s({ trig = ";", hidden = true }, fmt("{} = {};", { i(1, "attr"), i(2, "value") })),
  -- ''
  --   $1
  -- ''
  s({ trig = "''", hidden = true }, fmt("''\n\t{}\n''", i(1))),
  -- let
  --   $1
  -- in
  s(
    { trig = "let", dscr = "A let-expression" },
    cr(1, {
      fmte("let\n\t{}\nin", r(1, 1, i(1))),
      fmte("let {} in", r(1, 1)),
    })
  ),
  -- inherit () ;
  s(
    { trig = "inherit", dscr = "Inheriting attributes" },
    c(1, {
      fmte("inherit ({}) {};", { i(1, "src-set"), r(2, 1, i(1, "attr")) }),
      fmte("inherit {};", r(1, 1)),
    })
  ),
}
