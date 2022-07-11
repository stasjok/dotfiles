local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local d = require("luasnip.nodes.dynamicNode").D
local r = require("luasnip.nodes.restoreNode").R
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local cr = require("snippets.nodes").cr
local expand_conds = require("snippets.expand_conditions")
local show_conds = require("snippets.show_conditions")
local utils = require("snippets.jinja_utils")

-- Jinja statements
local snippets = utils.jinja_statement_snippets({
  ["for"] = {
    dscr = "For loop",
    nodes = { i(1, "item"), t(" in "), i(2, "list") },
  },
  ["do"] = {
    dscr = "Expression statement",
    nodes = cr(1, {
      r(1, "var", i(nil, "var")),
      { r(1, "var"), t(".append("), r(2, "x", i(nil)), t(")") },
      { r(1, "var"), t(".update("), r(2, "x"), t(")") },
    }),
    block = false,
    inline = false,
  },
  ["if"] = {
    dscr = "If statement",
    nodes = i(1, "condition"),
  },
  ["else"] = {
    dscr = "Else statement",
    block = false,
    append_newline = true,
  },
  elif = {
    dscr = "Elif statement",
    nodes = i(1, "condition"),
    block = false,
    append_newline = true,
  },
  macro = {
    dscr = "Macro definition",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
    trim_block = true,
    inline = false,
  },
  call = {
    dscr = "Call block",
    nodes = { i(1, "macro_name"), t("("), i(2), t(")") },
    trim_block = true,
  },
  filter = {
    dscr = "Filter block",
    nodes = i(1, "filter_name"),
  },
  raw = {
    dscr = "Raw block",
  },
  include = {
    dscr = "Include tag",
    nodes = {
      t('"'),
      cr(1, {
        { r(1, "filename", i(nil, "filename")), t('"') },
        { r(1, "filename"), t('" ignore missing') },
        { r(1, "filename"), t('" without context') },
        { r(1, "filename"), t('" ignore missing without context') },
      }),
    },
    block = false,
    inline = false,
  },
  import = {
    dscr = "Import tag",
    nodes = {
      t('"'),
      cr(1, {
        r(1, "statement", {
          i(1, "filename"),
          t('"'),
          n(2, " as ", ""),
          dl(2, l._1:match("[^/]*$"):match("^[^.]*"), 1),
        }),
        { r(1, "statement"), t(" with context") },
      }),
    },
    block = false,
    inline = false,
  },
  from = {
    dscr = "Import specific names from a template",
    nodes = {
      t('"'),
      cr(1, {
        r(1, "statement", {
          i(1, "filename"),
          t('" import '),
          i(2, "name"),
        }),
        { r(1, "statement"), t(" with context") },
      }),
    },
    block = false,
    inline = false,
  },
  block = {
    dscr = "Block tag",
    nodes = i(1, "tag"),
  },
  extends = {
    dscr = "Extend tag",
    nodes = { t('"'), i(1, "filename"), t('"') },
    block = false,
    inline = false,
  },
})

table.insert(
  snippets,
  s({ trig = "set", dscr = "Variable assignment" }, {
    cr(1, {
      {
        d(1, utils.block_start),
        t("set "),
        r(2, 1, i(1, "var")),
        t(" = "),
        r(3, 2, i(1, "value")),
        t(" %}"),
      },
      {
        d(1, utils.block_start),
        t("set "),
        r(2, 1),
        p(utils.block_end(true)),
        t({ "", "" }),
        r(3, 2),
        t({ "", "" }),
        rep(1),
        t("endset %}"),
      },
      {
        t("{% set "),
        r(1, 1),
        t(" %}"),
        r(2, 2),
        t("{% endset %}"),
      },
    }),
  }, {
    condition = expand_conds.is_line_beginning,
    show_condition = show_conds.is_line_beginning(),
  })
)

return snippets
