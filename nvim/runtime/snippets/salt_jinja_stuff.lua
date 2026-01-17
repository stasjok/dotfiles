local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local n = require("luasnip.extras").nonempty

return {
  s({ trig = "raise", dscr = "Raise custom error" }, {
    t('raise("'),
    i(1, "Custom Error"),
    t('")'),
  }),
  s({
    trig = "show_full_context",
    dscr = "Output all variables present in the current Jinja context",
  }, {
    t("show_full_context()"),
  }),
  s({ trig = "salt", dscr = "Call a Salt function" }, {
    t('salt["'),
    c(1, {
      {
        i(1, "grains.get"),
        t('"]("'),
        c(2, {
          i(1, "os_family"),
          i(1, "os"),
          i(1, "osfinger"),
          i(1, "osmajorrelease"),
          i(1, "oscodename"),
          i(1, "id"),
          i(1, "host"),
          i(1, "fqdn"),
          i(1, "virtual"),
        }),
        t('"'),
      },
      {
        i(1, "config.get"),
        t('"]("'),
        r(2, 1, { i(1, "key"), t('"'), n(2, ", ", ""), i(2, "default") }),
      },
      {
        i(1, "pillar.get"),
        t('"]("'),
        r(2, 1),
      },
      {
        i(1, "slsutil.boolstr"),
        t('"]('),
        i(2, "value"),
        t(", "),
        i(3, "if_true"),
        t(", "),
        i(4, "if_false"),
      },
      {
        i(1, "slsutil.merge"),
        t('"]('),
        i(2, "obj_a"),
        t(", "),
        i(3, "obj_b"),
      },
      {
        i(1, "slsutil.merge_all"),
        t('"](['),
        i(2),
        t("]"),
      },
      {
        i(1, "slsutil.banner"),
        t('"]('),
        c(2, {
          r(1, 2, i(1)),
          {
            r(1, 2),
            n(1, ", ", ""),
            t('commentchar=" *", borderchar="*", blockstart="/**", blockend=" */"'),
          },
        }),
      },
    }),
    t(")"),
  }),
}
