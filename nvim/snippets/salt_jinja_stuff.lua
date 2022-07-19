local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I

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
}
