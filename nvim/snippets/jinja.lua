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
local wn = require("snippets.nodes").wrapped_nodes
local select_dedent = require("snippets.functions").select_dedent
local expand_conds = require("snippets.expand_conditions")
local show_conds = require("snippets.show_conditions")

local snippets = {}

for statement, opts in pairs({
  ["for"] = {
    dscr = "For loop",
    nodes = { i(1, "item"), t(" in "), i(2, "list") },
  },
  ["if"] = {
    dscr = "If statement",
    nodes = i(1, "condition"),
  },
  macro = {
    dscr = "Macro definition",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
    trim = "-",
    inline = false,
  },
  call = {
    dscr = "Call block",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
    trim = "-",
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
      wn(1, opts.nodes, true),
      t({ " " .. (opts.trim or "") .. "%}", "" }),
      f(select_dedent),
      i(0),
      t({ "", "{%- end" .. statement .. " %}" }),
    }, {
      condition = expand_conds.is_line_beginning,
      show_condition = show_conds.is_line_beginning(),
    })
  )
  if opts.inline ~= false then
    table.insert(
      snippets,
      s({ trig = statement, dscr = "Inline " .. (opts.dscr or statement), wordTrig = false }, {
        t("{% " .. statement .. (opts.space or " ")),
        wn(1, opts.nodes, true),
        t(" %}"),
        f(select_dedent),
        i(0),
        t("{% end" .. statement .. " %}"),
      }, {
        show_condition = show_conds.is_not_line_beginning(),
      })
    )
  end
end

return snippets
