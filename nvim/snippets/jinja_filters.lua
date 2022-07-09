local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local n = require("luasnip.extras").nonempty
local cr = require("snippets.nodes").cr
local jinja_filter_snippets = require("snippets.jinja_utils").jinja_filter_snippets

-- Jinja filters
return jinja_filter_snippets({
  abs = { nodes = false },
  attr = { nodes = { t('"'), i(1, "name"), t('"') } },
  batch = {
    nodes = cr(1, {
      r(1, 1, i(nil, "count")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
    }),
  },
  capitalize = { nodes = false },
  center = { nodes = i(1, "width") },
  default = {
    nodes = cr(1, {
      r(1, 1, i(nil, "default_value")),
      { r(1, 1), t(", true") },
    }),
  },
  dictsort = {
    nodes = c(1, {
      i(1),
      t("case_sensitive=true"),
      t('by="value"'),
      t("reverse=true"),
      t('case_sensitive=true, by="value"'),
      t("case_sensitive=true, reverse=true"),
      t('by="value", reverse=true'),
      t('case_sensitive=true, by="value", reverse=true'),
    }),
  },
  escape = { nodes = false },
  filesizeformat = { nodes = c(1, { t(""), t("true") }) },
  first = { nodes = false },
  float = { nodes = c(1, { t(""), i(nil, "default") }) },
  forceescape = { nodes = false },
  format = { nodes = true },
  groupby = {
    nodes = cr(1, {
      r(1, 1, i(nil, "attribute")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "default")) },
      { r(1, 1), t(", case_sensitive=true") },
      { r(1, 1), t(", "), r(2, 2), t(", case_sensitive=true") },
    }),
  },
  indent = {
    nodes = cr(1, {
      r(1, 1, i(nil, "width")),
      { r(1, 1), t(", first=true") },
      { r(1, 1), t(", blank=true") },
      { r(1, 1), t(", first=true, blank=true") },
    }),
  },
  int = {
    nodes = c(1, {
      t(""),
      r(1, 1, i(nil, "default")),
      { t("base="), r(1, 2, i(nil, "base")) },
      { r(1, 1), t(", "), r(2, 2) },
    }),
  },
  items = { nodes = false },
  join = {
    nodes = cr(1, {
      r(nil, 1, { t('"'), i(1, ","), t('"') }),
      { r(1, 1), r(2, 2, { t(', attribute="'), i(1, "attr"), t('"') }) },
    }),
  },
  last = { nodes = false },
  length = { nodes = false },
  list = { nodes = false },
  lower = { nodes = false },
  map = {
    nodes = cr(1, {
      { t('"'), i(1, "filter"), t('"') },
      r(1, 1, { t("attribute="), i(1, "attr") }),
      { r(1, 1), t(", default="), i(2, "val") },
    }),
  },
  max = {
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  min = {
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  pprint = { nodes = false },
  random = { nodes = false },
  reject = { nodes = { t('"'), i(1, "test"), t('"') } },
  rejectattr = { nodes = { i(1, "attr"), t(', "'), i(2, "test"), t('"') } },
  replace = {
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "old"), t('", "'), i(2, "new"), t('"') }),
      { r(1, 1), t(", "), i(2, "count") },
    }),
  },
  reverse = { nodes = false },
  round = {
    nodes = cr(1, {
      r(1, 1, i(1)),
      { r(1, 1), n(1, ", "), t('method="ceil"') },
      { r(1, 1), n(1, ", "), t('method="floor"') },
    }),
  },
  safe = { nodes = false },
  select = { nodes = { t('"'), i(1, "test"), t('"') } },
  selectattr = { nodes = { i(1, "attr"), t(', "'), i(2, "test"), t('"') } },
  slice = {
    nodes = cr(1, {
      r(1, 1, i(nil, "slices")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
    }),
  },
  sort = {
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("reverse=true"),
      t("case_sensitive=true"),
      { r(1, 1), t(", reverse=true") },
      { r(1, 1), t(", case_sensitive=true") },
      t("reverse=true, case_sensitive=true"),
      { r(1, 1), t(", reverse=true, case_sensitive=true") },
    }),
  },
  string = { nodes = false },
  striptags = { nodes = false },
  sum = {
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      r(1, 2, { t("start="), i(1, "0") }),
      { r(1, 1), t(", "), r(2, 2) },
    }),
  },
  title = { nodes = false },
  tojson = { nodes = true },
  trim = { nodes = true },
  truncate = {
    nodes = cr(1, {
      r(1, 1, i(1, "length")),
      { r(1, 1), t(", killwords=true") },
      { r(1, 1), t(", "), r(2, 2, { t('end="'), i(1, "..."), t('"') }) },
      { r(1, 1), t(", "), r(2, 3, { t("leeway="), i(1, "0") }) },
      { r(1, 1), t(", killwords=true, "), r(2, 2) },
      { r(1, 1), t(", killwords=true, "), r(2, 3) },
      { r(1, 1), t(", "), r(2, 2), t(", "), r(3, 3) },
      { r(1, 1), t(", killwords=true, "), r(2, 2), t(", "), r(3, 3) },
    }),
  },
  unique = {
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  upper = { nodes = false },
  urlencode = { nodes = false },
  urlize = { nodes = true },
  wordcount = { nodes = false },
  wordwrap = {
    nodes = cr(1, {
      r(1, 1, i(1, "width")),
      { r(1, 1), t(", break_long_words=false") },
      { r(1, 1), t(", break_on_hyphens=false") },
      { r(1, 1), t(", "), r(2, 2, { t('wrapstring="'), i(1), t('"') }) },
      { r(1, 1), t(", break_long_words=false, break_on_hyphens=false") },
      { r(1, 1), t(", break_long_words=false, "), r(2, 2) },
      { r(1, 1), t(", break_on_hyphens=false, "), r(2, 2) },
      { r(1, 1), t(", break_long_words=false, break_on_hyphens=false, "), r(2, 2) },
    }),
  },
  xmlattr = { nodes = c(1, { t(""), t("false") }) },
})
