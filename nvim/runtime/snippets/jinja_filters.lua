local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local n = require("luasnip.extras").nonempty
local cr = require("snippets.nodes").cr
local jinja_filter_snippets = require("snippets.jinja_utils").jinja_filter_snippets

-- Jinja filters
return jinja_filter_snippets({
  abs = { dscr = "Return the absolute value of the argument" },
  attr = { dscr = "Get an attribute of an object", nodes = { t('"'), i(1, "name"), t('"') } },
  batch = {
    dscr = "Returns a list of lists with the given number of items",
    nodes = cr(1, {
      r(1, 1, i(nil, "count")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
    }),
  },
  capitalize = { dscr = "Capitalize a value" },
  center = { dscr = "Centers the value in a field of a given width", nodes = i(1, "width") },
  default = {
    dscr = "If the value is undefined it will return the passed default value",
    nodes = cr(1, {
      r(1, 1, i(nil, "default_value")),
      { r(1, 1), t(", true") },
    }),
  },
  dictsort = {
    dscr = "Sort a dict and yield (key, value) pairs",
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
  escape = {
    dscr = "Replace the characters `&`, `<`, `>`, `'`, and `\"` in the string with HTML-safe sequences",
  },
  filesizeformat = {
    dscr = "Format the value like a 'human-readable' file size",
    nodes = c(1, { t(""), t("true") }),
  },
  first = { dscr = "Return the first item of a sequence" },
  float = {
    dscr = "Convert the value into a floating point number",
    nodes = c(1, { t(""), i(nil, "default") }),
  },
  forceescape = { dscr = "Enforce HTML escaping" },
  format = {
    dscr = "Apply the given values to a printf-style format string, like `string % values`",
    nodes = true,
  },
  groupby = {
    dscr = "Group a sequence of objects by an attribute",
    nodes = cr(1, {
      r(1, 1, i(nil, "attribute")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "default")) },
      { r(1, 1), t(", case_sensitive=true") },
      { r(1, 1), t(", "), r(2, 2), t(", case_sensitive=true") },
    }),
  },
  indent = {
    dscr = "Return a copy of the string with each line indented",
    nodes = cr(1, {
      r(1, 1, i(nil, "width")),
      { r(1, 1), t(", first=true") },
      { r(1, 1), t(", blank=true") },
      { r(1, 1), t(", first=true, blank=true") },
    }),
  },
  int = {
    dscr = "Convert the value into an integer",
    nodes = c(1, {
      t(""),
      r(1, 1, i(nil, "default")),
      { t("base="), r(1, 2, i(nil, "base")) },
      { r(1, 1), t(", "), r(2, 2) },
    }),
  },
  items = { dscr = "Return an iterator over the `(key, value)` items of a mapping" },
  join = {
    dscr = "Return a string which is the concatenation of the strings in the sequence",
    nodes = cr(1, {
      r(nil, 1, { t('"'), i(1, ","), t('"') }),
      { r(1, 1), r(2, 2, { t(', attribute="'), i(1, "attr"), t('"') }) },
    }),
  },
  last = { dscr = "Return the last item of a sequence" },
  length = { dscr = "Return the number of items in a container" },
  list = { dscr = "Convert the value into a list" },
  lower = { dscr = "Convert a value to lowercase" },
  map = {
    dscr = "Applies a filter on a sequence of objects or looks up an attribute",
    nodes = cr(1, {
      { t('"'), i(1, "filter"), t('"') },
      r(1, 1, { t("attribute="), i(1, "attr") }),
      { r(1, 1), t(", default="), i(2, "val") },
    }),
  },
  max = {
    dscr = "Return the largest item from the sequence",
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  min = {
    dscr = "Return the smallest item from the sequence",
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  pprint = { dscr = "Pretty print a variable" },
  random = { dscr = "Return a random item from the sequence" },
  reject = {
    dscr = "Filters a sequence of objects by applying a test to each object",
    nodes = { t('"'), i(1, "test"), t('"') },
  },
  rejectattr = {
    dscr = "Filters a sequence of objects by applying a test to the specified attribute of each object",
    nodes = { i(1, "attr"), t(', "'), i(2, "test"), t('"') },
  },
  replace = {
    dscr = "Return a copy of the value with all occurrences of a substring replaced with a new one",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "old"), t('", "'), i(2, "new"), t('"') }),
      { r(1, 1), t(", "), i(2, "count") },
    }),
  },
  reverse = {
    dscr = "Reverse the object or return an iterator that iterates over it the other way round",
  },
  round = {
    dscr = "Round the number to a given precision",
    nodes = cr(1, {
      r(1, 1, i(1)),
      { r(1, 1), n(1, ", "), t('method="ceil"') },
      { r(1, 1), n(1, ", "), t('method="floor"') },
    }),
  },
  safe = { dscr = "Mark the value as safe which means this variable will not be escaped" },
  select = {
    dscr = "Filters a sequence of objects by applying a test to each object",
    nodes = { t('"'), i(1, "test"), t('"') },
  },
  selectattr = {
    dscr = "Filters a sequence of objects by applying a test to the specified attribute of each object",
    nodes = { i(1, "attr"), t(', "'), i(2, "test"), t('"') },
  },
  slice = {
    dscr = "Slice an iterator and return a list of lists containing those items",
    nodes = cr(1, {
      r(1, 1, i(nil, "slices")),
      { r(1, 1), t(", "), r(2, 2, i(nil, "fill_with")) },
    }),
  },
  sort = {
    dscr = "Sort an iterable",
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
  string = { dscr = "Convert an object to a string if it isn’t already" },
  striptags = { dscr = "Strip SGML/XML tags and replace adjacent whitespace by one space" },
  sum = {
    dscr = "Returns the sum of a sequence of numbers",
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      r(1, 2, { t("start="), i(1, "0") }),
      { r(1, 1), t(", "), r(2, 2) },
    }),
  },
  title = { dscr = "Return a titlecased version of the value" },
  tojson = { dscr = "Serialize an object to a string of JSON", nodes = true },
  trim = { dscr = "Strip leading and trailing characters, by default whitespace", nodes = true },
  truncate = {
    dscr = "Return a truncated copy of the string",
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
    dscr = "Returns a list of unique items from the given iterable",
    nodes = c(1, {
      t(""),
      r(1, 1, { t("attribute="), i(1, "attr") }),
      t("case_sensitive=true"),
      { r(1, 1), t(", case_sensitive=true") },
    }),
  },
  upper = { dscr = "Convert a value to uppercase" },
  urlencode = { dscr = "Quote data for use in a URL path" },
  urlize = { dscr = "Convert URLs in text into clickable links", nodes = true },
  wordcount = { dscr = "Count the words in that string" },
  wordwrap = {
    dscr = "Wrap a string to the given width",
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
  xmlattr = {
    dscr = "Create an SGML/XML attribute string based on the items in a dict",
    nodes = c(1, { t(""), t("false") }),
  },
})
