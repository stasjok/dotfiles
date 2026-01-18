local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local conds = require("snippets.expand_conditions")
local show_conds = require("snippets.show_conditions")

local snippets = {
  s({ trig = ".PHONY", dscr = "Phony Target" }, {
    t(".PHONY : "),
    rep(1),
    t({ "", "" }),
    i(1, "target"),
    t(" :"),
  }, {
    condition = conds.is_line_beginning,
    show_condition = show_conds.is_line_beginning("%w."),
  }),
}

return snippets
