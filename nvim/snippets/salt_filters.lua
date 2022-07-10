local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local cr = require("snippets.nodes").cr
local jinja_filter_snippets = require("snippets.jinja_utils").jinja_filter_snippets

-- SaltStack jinja filters
return jinja_filter_snippets({
  strftime = {
    dscr = "Converts date into a time-based string",
    nodes = c(1, { t(""), { t('"'), i(1, "format"), t('"') } }),
  },
  sequence = { dscr = "Ensure that parsed data is a sequence" },
  yaml_encode = { dscr = "Serializes a single object into a YAML scalar" },
  yaml_dquote = { dscr = "Serializes a string into a properly-escaped YAML double-quoted string" },
  yaml_squote = { dscr = "Serializes a string into a properly-escaped YAML single-quoted string" },
  to_bool = { dscr = "Returns the logical value of an element" },
  exactly_n_true = {
    dscr = 'Tests that exactly N items in an iterable are "truthy"',
    nodes = i(1, "amount"),
  },
  exactly_one_true = { dscr = 'Tests that exactly one item in an iterable is "truthy"' },
  quote = { dscr = "Return a shell-escaped version of the string" },
  regex_search = {
    dscr = "Searches for a pattern in a string, returns a tuple containing all the subgroups of the match",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "pattern"), t('"') }),
      { r(1, 1), t(", ignorecase=true") },
      { r(1, 1), t(", multiline=true") },
      { r(1, 1), t(", multiline=true, multiline=true") },
    }),
  },
  regex_match = {
    dscr = "Searches for a pattern at the beginning of a string, returns a tuple containing all the subgroups of the match",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "pattern"), t('"') }),
      { r(1, 1), t(", ignorecase=true") },
      { r(1, 1), t(", multiline=true") },
      { r(1, 1), t(", multiline=true, multiline=true") },
    }),
  },
  regex_replace = {
    dscr = "Searches for a pattern and replaces with a string",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "pattern"), t('", "'), i(2, "repl"), t('"') }),
      { r(1, 1), t(", ignorecase=true") },
      { r(1, 1), t(", multiline=true") },
      { r(1, 1), t(", multiline=true, multiline=true") },
    }),
  },
  uuid = { dscr = "Returns a UUID corresponding to the value" },
  is_list = { dscr = "Returns true if an object is list" },
  is_iter = { dscr = "Test if an object is iterable, but not a string type" },
  min = { dscr = "Return the minimum value from a list" },
  max = { dscr = "Returns the maximum value from a list" },
  avg = { dscr = "Returns the average value of the elements of a list" },
  union = { dscr = "Return the union of two lists", nodes = i(1, "list") },
  intersect = { dscr = "Returns the intersection of two lists", nodes = i(1, "list") },
  difference = { dscr = "Return the difference of two lists", nodes = i(1, "list") },
  symmetric_difference = {
    dscr = "Returns the symmetric difference of two lists",
    nodes = { i(1, "list") },
  },
  method_call = {
    dscr = "Returns a result of object's method call",
    nodes = cr(1, { r(1, 1, { t('"'), i(1, "name"), t('"') }), { r(1, 1), t(", "), i(2) } }),
  },
  compare_lists = {
    dscr = "Compare two lists and return a dictionary with the changes",
    nodes = { i(1, "list") },
  },
  compare_dicts = {
    dscr = "Compare two dictionaries and return a dictionary with the changes",
    nodes = { i(1, "dict") },
  },
  is_hex = { dscr = "Returns true if value is a hexadecimal string" },
  contains_whitespace = { dscr = "Return true if a text contains whitespaces" },
  substring_in_list = {
    dscr = "Return true if a substring is found in a list of string values",
    nodes = i(1, "list"),
  },
  check_whitelist_blacklist = {
    dscr = "Check a whitelist and/or blacklist to see if the value matches it",
    nodes = c(1, {
      r(1, "white", { t("whitelist="), i(1) }),
      r(1, "black", { t("blacklist="), i(1) }),
      { r(1, "white"), t(", "), r(2, "black") },
    }),
  },
  date_format = {
    dscr = "Converts date into a time-based string",
    nodes = c(1, { t(""), { t('"'), i(1, "format"), t('"') } }),
  },
  to_num = { dscr = "Converts a string to its numerical value" },
  to_bytes = {
    dscr = "Converts string-type object to bytes",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "encoding"), t('"') },
    }),
  },
})
