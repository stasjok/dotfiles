local s = require("luasnip.nodes.snippet").S
local sn = require("luasnip.nodes.snippet").SN
local t = require("luasnip.nodes.textNode").T
local f = require("luasnip.nodes.functionNode").F
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local d = require("luasnip.nodes.dynamicNode").D
local r = require("luasnip.nodes.restoreNode").R
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local types = require("luasnip.util.types")
local events = require("luasnip.util.events")
local parse = require("luasnip.util.parser").parse_snippet
local ai = require("luasnip.nodes.absolute_indexer")
local cr = require("snippets.nodes").cr

local snippets = {}
for statement, opts in pairs({
  ["for"] = {
    nodes = cr(1, {
      { r(1, 1, i(nil, "item")), t(" in "), r(2, 2, i(nil, "list")) },
      { r(1, 1), t(" in "), r(2, 2), t(" if "), i(3, "filter") },
    }),
  },
  ["if"] = {
    dscr = "If statement",
    nodes = i(1, "condition"),
  },
  macro = {
    dscr = "Macro definition",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
    trim = "-",
  },
  call = {
    dscr = "Call block",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
  },
  filter = {
    dscr = "Filter section",
    nodes = i(1, "filter_name"),
  },
  block = {
    dscr = "Block tag",
    nodes = i(1, "tag"),
  },
  raw = {
    dscr = "Raw block",
    nodes = {},
    space = "",
  },
}) do
  table.insert(
    snippets,
    s({ trig = statement, dscr = opts.dscr or statement }, {
      t("{%- " .. statement .. (opts.space or " ")),
      sn(1, opts.nodes),
      t({ " " .. (opts.trim or "") .. "%}", "" }),
      f(function(_, snip)
        return snip.env.SELECT_DEDENT
      end),
      i(0),
      t({ "", "{%- end" .. statement .. " %}" }),
    }, {
      condition = conds.line_begin,
      show_condition = function(line_to_cursor)
        return line_to_cursor:find("^%s*%a*$")
      end,
    })
  )
end

return snippets
