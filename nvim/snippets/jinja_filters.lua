local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local n = require("luasnip.extras").nonempty
local cr = require("snippets.nodes").cr
local jinja_nodes_for_filter = require("snippets.jinja_utils").jinja_nodes_for_filter

local snippets = {}

-- Jinja filters
for filter, nodes in pairs({
  abs = false,
  attr = { t('"'), i(1, "name"), t('"') },
  batch = cr(1, {
    r(1, 1, i(nil, "count")),
    { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
  }),
  capitalize = false,
  center = i(1, "width"),
  default = cr(1, {
    r(1, 1, i(nil, "default_value")),
    { r(1, 1), t(", true") },
  }),
  dictsort = c(1, {
    i(1),
    t("case_sensitive=true"),
    t('by="value"'),
    t("reverse=true"),
    t('case_sensitive=true, by="value"'),
    t("case_sensitive=true, reverse=true"),
    t('by="value", reverse=true'),
    t('case_sensitive=true, by="value", reverse=true'),
  }),
  escape = false,
  filesizeformat = c(1, { t(""), t("true") }),
  first = false,
  float = c(1, { t(""), i(nil, "default") }),
  forceescape = false,
  format = true,
  groupby = cr(1, {
    r(1, 1, i(nil, "attribute")),
    { r(1, 1), t(", "), r(2, 2, i(nil, "default")) },
    { r(1, 1), t(", case_sensitive=true") },
    { r(1, 1), t(", "), r(2, 2), t(", case_sensitive=true") },
  }),
  indent = cr(1, {
    r(1, 1, i(nil, "width")),
    { r(1, 1), t(", first=true") },
    { r(1, 1), t(", blank=true") },
    { r(1, 1), t(", first=true, blank=true") },
  }),
  int = c(1, {
    t(""),
    r(1, 1, i(nil, "default")),
    { t("base="), r(1, 2, i(nil, "base")) },
    { r(1, 1), t(", "), r(2, 2) },
  }),
  items = false,
  join = cr(1, {
    r(nil, 1, { t('"'), i(1, ","), t('"') }),
    { r(1, 1), r(2, 2, { t(', attribute="'), i(1, "attr"), t('"') }) },
  }),
  last = false,
  length = false,
  list = false,
  lower = false,
  map = cr(1, {
    { t('"'), i(1, "filter"), t('"') },
    r(1, 1, { t("attribute="), i(1, "attr") }),
    { r(1, 1), t(", default="), i(2, "val") },
  }),
  max = c(1, {
    t(""),
    r(1, 1, { t("attribute="), i(1, "attr") }),
    t("case_sensitive=true"),
    { r(1, 1), t(", case_sensitive=true") },
  }),
  min = c(1, {
    t(""),
    r(1, 1, { t("attribute="), i(1, "attr") }),
    t("case_sensitive=true"),
    { r(1, 1), t(", case_sensitive=true") },
  }),
  pprint = false,
  random = false,
  reject = { t('"'), i(1, "test"), t('"') },
  rejectattr = { i(1, "attr"), t(', "'), i(2, "test"), t('"') },
  replace = cr(1, {
    r(1, 1, { t('"'), i(1, "old"), t('", "'), i(2, "new"), t('"') }),
    { r(1, 1), t(", "), i(2, "count") },
  }),
  reverse = false,
  round = cr(1, {
    r(1, 1, i(1)),
    { r(1, 1), n(1, ", "), t('method="ceil"') },
    { r(1, 1), n(1, ", "), t('method="floor"') },
  }),
  safe = false,
  select = { t('"'), i(1, "test"), t('"') },
  selectattr = { i(1, "attr"), t(', "'), i(2, "test"), t('"') },
  slice = cr(1, {
    r(1, 1, i(nil, "slices")),
    { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
  }),
  sort = c(1, {
    t(""),
    r(1, 1, { t("attribute="), i(1, "attr") }),
    t("reverse=true"),
    t("case_sensitive=true"),
    { r(1, 1), t(", reverse=true") },
    { r(1, 1), t(", case_sensitive=true") },
    t("reverse=true, case_sensitive=true"),
    { r(1, 1), t(", reverse=true, case_sensitive=true") },
  }),
  string = false,
  striptags = false,
  sum = c(1, {
    t(""),
    r(1, 1, { t("attribute="), i(1, "attr") }),
    r(1, 2, { t("start="), i(1, "0") }),
    { r(1, 1), t(", "), r(2, 2) },
  }),
  title = false,
  tojson = true,
  trim = true,
  truncate = cr(1, {
    r(1, 1, i(1, "length")),
    { r(1, 1), t(", killwords=true") },
    { r(1, 1), t(", "), r(2, 2, { t('end="'), i(1, "..."), t('"') }) },
    { r(1, 1), t(", "), r(2, 3, { t("leeway="), i(1, "0") }) },
    { r(1, 1), t(", killwords=true, "), r(2, 2) },
    { r(1, 1), t(", killwords=true, "), r(2, 3) },
    { r(1, 1), t(", "), r(2, 2), t(", "), r(3, 3) },
    { r(1, 1), t(", killwords=true, "), r(2, 2), t(", "), r(3, 3) },
  }),
  unique = c(1, {
    t(""),
    r(1, 1, { t("attribute="), i(1, "attr") }),
    t("case_sensitive=true"),
    { r(1, 1), t(", case_sensitive=true") },
  }),
  upper = false,
  urlencode = false,
  urlize = true,
  wordcount = false,
  wordwrap = cr(1, {
    r(1, 1, i(1, "width")),
    { r(1, 1), t(", break_long_words=false") },
    { r(1, 1), t(", break_on_hyphens=false") },
    { r(1, 1), t(", "), r(2, 2, { t('wrapstring="'), i(1), t('"') }) },
    { r(1, 1), t(", break_long_words=false, break_on_hyphens=false") },
    { r(1, 1), t(", break_long_words=false, "), r(2, 2) },
    { r(1, 1), t(", break_on_hyphens=false, "), r(2, 2) },
    { r(1, 1), t(", break_long_words=false, break_on_hyphens=false, "), r(2, 2) },
  }),
  xmlattr = c(1, { t(""), t("false") }),
}) do
  nodes = jinja_nodes_for_filter(filter, nodes)
  table.insert(snippets, s({ trig = filter, dscr = "`" .. filter .. "` filter" }, nodes))
end

return snippets
