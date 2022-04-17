local s = require("luasnip.nodes.snippet").S
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local fmt = require("luasnip.extras.fmt").fmt

local ts_utils = require("nvim-treesitter.ts_utils")

local function cr(pos, choices)
  return c(pos, choices, { restore_cursor = true })
end

local function fmte(str, nodes)
  return fmt(str, nodes, { trim_empty = false, dedent = false })
end

local function is_in_ts_node(nodes)
  if type(nodes) == "string" then
    nodes = { nodes }
  end
  local node_at_cursor = ts_utils.get_node_at_cursor()
  if node_at_cursor then
    return vim.tbl_contains(nodes, node_at_cursor:type())
  end
end

return {
  -- attr = value;
  s({ trig = ";", hidden = true }, fmt("{} = {};", { i(1, "attr"), i(2, "value") }), {
    condition = function()
      return is_in_ts_node({ "attrset", "let" })
    end,
  }),
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
