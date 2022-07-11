local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local r = require("luasnip.nodes.restoreNode").R
local n = require("luasnip.extras").nonempty
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
  regex_escape = { dscr = "Escape all the characters in a string except letters, numbers and '_'" },
  uuid = { dscr = "Returns a UUID corresponding to the value" },
  is_list = { dscr = "Returns true if an object is list" },
  is_iter = { dscr = "Test if an object is iterable, but not a string type" },
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
  sorted_ignorecase = { dscr = "Sort a list of strings ignoring case" },
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
  json_encode_list = {
    dscr = "Recursively encodes all string elements of the list to bytes",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "encoding"), t('"') },
    }),
  },
  json_encode_dict = {
    dscr = "Recursively encodes all string items in the dictionary to bytes",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "encoding"), t('"') },
    }),
  },
  random_hash = {
    dscr = "Generates a random number between 1 and the number passed to the filter, and then hashes it",
    nodes = c(1, { t(""), { t('"'), i(1, "sha256"), t('"') } }),
  },
  random_str = { dscr = "Returns random string with given length" },
  human_to_bytes = {
    dscr = "Given a human-readable byte string (e.g. 2G, 30MB, 64KiB), return the number of bytes",
    nodes = c(1, {
      t(""),
      r(1, 1, { t('default_unit="'), i(1, "B"), t('"') }),
      t("handle_metric=true"),
      { r(1, 1), t(", handle_metric=true") },
    }),
  },
  set_dict_key_value = {
    dscr = "Set a value in a nested dictionary",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "keys"), t('", '), i(2, "value") }),
      { r(1, 1), t(', delimiter="'), i(2, ":"), t('"') },
    }),
  },
  append_dict_key_value = {
    dscr = "Append to a list nested (deep) in a dictionary",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "keys"), t('", '), i(2, "value") }),
      { r(1, 1), t(', delimiter="'), i(2, ":"), t('"') },
    }),
  },
  extend_dict_key_value = {
    dscr = "Extend a list nested (deep) in a dictionary",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "keys"), t('", '), i(2, "list") }),
      { r(1, 1), t(', delimiter="'), i(2, ":"), t('"') },
    }),
  },
  update_dict_key_value = {
    dscr = "Update a dictionary nested (deep) in another dictionary",
    nodes = cr(1, {
      r(1, 1, { t('"'), i(1, "keys"), t('", '), i(2, "dict") }),
      { r(1, 1), t(', delimiter="'), i(2, ":"), t('"') },
    }),
  },
  md5 = { dscr = "Return the md5 digest of a string" },
  sha1 = { dscr = "Return the sha1 digest of a string" },
  sha256 = { dscr = "Return the sha256 digest of a string" },
  sha512 = { dscr = "Return the sha512 digest of a string" },
  base64_encode = { dscr = "Encode a string as base64" },
  base64_decode = { dscr = "Decode a base64-encoded string" },
  hmac = {
    dscr = "Verify a challenging hmac signature against a string / shared-secret",
    nodes = { t('"'), i(1, "shared_secret"), t('", "'), i(2, "challenge_hmac"), t('"') },
  },
  hmac_compute = {
    dscr = "Create an hmac digest",
    nodes = { t('"'), i(1, "shared_secret"), t('"') },
  },
  http_query = { dscr = "Return the HTTP reply object from a URL", nodes = true },
  traverse = {
    dscr = "Traverse a dict or list using a colon-delimited target string",
    nodes = cr(1, {
      r(1, "keys", { t('"'), i(1, "keys"), t('"') }),
      { r(1, "keys"), t(", "), r(2, "default", i(nil, "default")) },
      { r(1, "keys"), t(", "), r(2, "delim", { t('delimiter="'), i(1, ":"), t('"') }) },
      { r(1, "keys"), t(", "), r(2, "default"), t(", "), r(3, "delim") },
    }),
  },
  json_query = {
    dscr = "Make queries against JSON data using JMESPath language",
    nodes = { t('"'), i(1, "query"), t('"') },
  },
  to_snake_case = { dscr = "Converts a string from camelCase (or CamelCase) to snake_case" },
  to_camelcase = {
    dscr = "Converts a string from snake_case to camelCase (or UpperCamelCase)",
    nodes = c(1, {
      t(""),
      t("uppercamel=true"),
      t("true"),
    }),
  },
  is_ip = {
    dscr = "Return true if a string is a valid IP Address",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  is_ipv4 = {
    dscr = "Return true if a string is a valid IPv4 address",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  is_ipv6 = {
    dscr = "Return true if a string is a valid IPv6 address",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  ipaddr = {
    dscr = "From a list, returns only valid IP entries",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  ipv4 = {
    dscr = "From a list, returns only valid IPv4 entries",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  ipv6 = {
    dscr = "From a list, returns only valid IPv6 entries",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "global"), t('"') },
    }),
  },
  ip_host = {
    dscr = "From a list, returns only valid entries in interfaces format, e.g. 192.168.0.1/28",
    nodes = c(1, {
      t(""),
      r(1, 1, { t('"'), i(1, "global"), t('"') }),
      r(1, "v", { t("version="), i(1, "4") }),
      { r(1, 1), t(", "), r(2, "v") },
    }),
  },
  network_hosts = {
    dscr = "Return the list of hosts within a network",
    nodes = c(1, {
      t(""),
      r(1, 1, { t('"'), i(1, "global"), t('"') }),
      r(1, "v", { t("version="), i(1, "4") }),
      { r(1, 1), t(", "), r(2, "v") },
    }),
  },
  network_size = {
    dscr = "Return the size of the network",
    nodes = c(1, {
      t(""),
      r(1, 1, { t('"'), i(1, "global"), t('"') }),
      r(1, "v", { t("version="), i(1, "4") }),
      { r(1, 1), t(", "), r(2, "v") },
    }),
  },
  filter_by_networks = {
    dscr = "Returns the list of IPs filtered by the network list",
    nodes = i(1, "networks"),
  },
  gen_mac = {
    dscr = "Generates a MAC address with the defined OUI prefix",
    nodes = c(1, {
      t(""),
      { t('"'), i(1, "AC:DE:48"), t('"') },
    }),
  },
  mac_str_to_bytes = { dscr = "Converts a string representing a valid MAC address to bytes" },
  dns_check = {
    dscr = "Return the ip resolved by dns, tries to connect to the address before considering it useful",
    nodes = cr(1, {
      r(1, 1, i(1, "443")),
      { r(1, 1), t(", ipv6="), c(2, { t("false"), t("true"), t("none") }) },
    }),
  },
  is_text_file = {
    dscr = "Returns true if a file is text",
    nodes = c(1, { t(""), i(1, "512") }),
  },
  is_bin_file = { dscr = "Returns true if the file is a binary" },
  is_empty = { dscr = "Returns true if a file is empty" },
  file_hashsum = {
    dscr = "Returns the hashsum of a file",
    nodes = c(1, { t(""), { t('"'), i(1, "sha256"), t('"') } }),
  },
  list_files = { dscr = "Return a recursive list of files under a specific path" },
  path_join = {
    dscr = "Join one or more path components",
    nodes = cr(1, {
      r(1, 1, i(1)),
      { r(1, 1), t(", use_posixpath=true") },
    }),
  },
  which = { dscr = "Clone of /usr/bin/which" },
  mysql_to_dict = {
    dscr = "Convert MySQL-style output to a python dictionary",
    nodes = { t('"'), i(1, "key"), t('"') },
  },
  get_uid = { dscr = "Get the uid for a given user name" },
  skip = { dscr = "Suppress data output (returns empty string)" },
  yaml = {
    dscr = "Serialize an object to a string of YAML",
    nodes = c(1, { t(""), t("flow_style=false") }),
  },
  json = {
    dscr = "Serialize an object to a string of JSON",
    nodes = c(1, {
      t(""),
      t("sort_keys=false"),
      r(1, 1, { t("indent="), i(1, "2") }),
      { t("sort_keys=false"), t(", "), r(1, 1) },
    }),
  },
  xml = { dscr = "Render a formatted multi-line XML string from a complex Python data structure" },
  python = { dscr = "Serialize an object to a string of Python" },
  load_yaml = { dscr = "Deserialize a YAML string to object" },
  load_json = { dscr = "Deserialize a JSON string to object" },
  -- 3005
  flatten = {
    dscr = "Flatten a list",
    nodes = c(1, {
      t(""),
      r(1, 1, i(1, "1")),
      t("preserve_nulls=true"),
      { r(1, 1), t(", preserve_nulls=true") },
    }),
  },
  dict_to_sls_yaml_params = {
    dscr = "Render a YAML string from a dictionary as a list of single key-value pairs",
    nodes = c(1, { t(""), t("flow_style=true") }),
  },
  combinations = { dscr = "Returns n-length subsequences of elements", nodes = i(1, "2") },
  combinations_with_replacement = {
    dscr = "Returns n-length subsequences of elements allowing individual elements to be repeated",
    nodes = i(1, "2"),
  },
  compress = {
    dscr = "Filters elements returning only those that have a corresponding element evaluated to True",
    nodes = { i(1, "selectors") },
  },
  permutations = {
    dscr = "Return successive n-length permutations of elements",
    nodes = c(1, { t(""), i(1, "2") }),
  },
  product = {
    dscr = "Returns cartesian product",
    nodes = cr(1, {
      r(1, 1, i(1)),
      { r(1, 1), n(1, ", ", ""), t("repeat="), i(2, "2") },
    }),
  },
  zip = {
    dscr = "Aggregates elements from each of the iterables",
    nodes = i(1, "list"),
  },
  zip_longest = {
    dscr = "Aggregates elements from each of the iterables filling missing values with `fillvalue`",
    nodes = cr(1, {
      r(1, 1, i(1, "list")),
      { r(1, 1), t(", "), t("fillvalue="), i(2, "none") },
    }),
  },
})
