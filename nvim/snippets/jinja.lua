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

---Returns `true` if one of the `strings` are found in current file path
---@param strings string|string[]
---@return boolean
local function match_file_path(strings)
  strings = type(strings) == "table" and strings or { strings }
  ---@diagnostic disable-next-line: missing-parameter
  local path = vim.fn.expand("%:p:h")
  for _, str in ipairs(strings) do
    if path:find(str, 1, true) then
      return true
    end
  end
  return false
end

---Returns `true` if current jinja file is for SaltStack
---@return boolean
local function is_salt()
  return vim.bo.filetype == "sls" or match_file_path({ "salt", "formula" })
end

---Returns `true` if current jinja file is for Ansible
---@return boolean
local function is_ansible()
  return vim.bo.filetype == "yaml.ansible" or match_file_path({ "ansible", "role" })
end

---Returns a function for getting boolean option from a vim variable
---@param var string Variable for storing option
---@param default boolean | fun(): boolean Default value if variable is unset
---@return fun(): boolean
local function get_option(var, default)
  return function()
    local opt = vim.b[var]
    if opt ~= nil then
      if type(opt) ~= "boolean" then
        opt = opt ~= 0
      end
    else
      if type(default) == "function" then
        opt = default()
      else
        opt = default
      end
      vim.b[var] = opt
    end
    return opt
  end
end

---Is `trim_blocks` enabled?
local get_trim_block = get_option("jinja_trim_blocks", is_ansible)
---Is `lstrip_blocks` enabled?
local get_lstrip_blocks = get_option("jinja_lstrip_blocks", false)

---A function for dynamicNode that returns jinja block start
---@return table
local function block_start()
  local trim_blocks, lstrip_blocks = get_trim_block(), get_lstrip_blocks()
  local block = trim_blocks and "{% " or "{%- "
  local nodes = { t(block) }
  if not lstrip_blocks then
    table.insert(nodes, i(1))
  end
  return sn(nil, nodes)
end

---@alias JinjaGeneratorOpts {no_space?: boolean, end_statement?: string, trim_block?: boolean, append_newline?:boolean, condition?: function, show_condition?: function}

---Returns a function for creating a snippet for jinja block
---@param block boolean If `true` returns block statement
---@param inline boolean If `true` returns inline statement
local function jinja_statement_generator(block, inline)
  ---Returns a Jinja statement snippet for LuaSnip
  ---@param snip_args table First argument for LuaSnip snippet
  ---@param nodes? table A nodes inside a statement
  ---@param opts? JinjaGeneratorOpts Options affecting resulting snippet
  ---@return table
  return function(snip_args, nodes, opts)
    nodes = nodes or {}
    opts = opts or {}
    local statement = type(snip_args) == "string" and snip_args or snip_args.trig
    local end_statement = opts.end_statement or ("end" .. statement)
    if not opts.no_space and type(nodes) == "table" and not vim.tbl_isempty(nodes) then
      statement = statement .. " "
    end
    ---Returns restoreNode if block or snippetNode if not
    ---@param pos number Position
    ---@return table
    local function statement_nodes(pos)
      if block then
        return r(pos, "statement_nodes")
      else
        return wn(pos, nodes)
      end
    end
    local snip_nodes = {
      t("{% " .. statement),
      statement_nodes(1),
      t(" %}"),
    }
    if block then
      vim.list_extend(snip_nodes, {
        r(2, "content_nodes"),
        t("{% " .. end_statement .. " %}"),
      })
    end
    if not inline then
      local inline_nodes = snip_nodes
      local end_block
      local repeat_block
      if opts.trim_block then
        end_block = t(" -%}")
        repeat_block = l(l._1:gsub("^{%%  ?", "{%%- "), 1)
      else
        end_block = t(" %}")
        repeat_block = rep(1)
      end
      snip_nodes = {
        d(1, block_start),
        t(statement),
        statement_nodes(2),
        end_block,
      }
      if block then
        vim.list_extend(snip_nodes, {
          t({ "", "" }),
          r(3, "content_nodes"),
          t({ "", "" }),
          repeat_block,
          t(end_statement .. " %}"),
        })
        snip_nodes = {
          cr(1, {
            snip_nodes,
            inline_nodes,
          }),
        }
      end
    end
    if opts.append_newline and not inline then
      table.insert(snip_nodes, t({ "", "" }))
    end
    local stored = {}
    if block then
      stored = {
        statement_nodes = nodes,
        content_nodes = { f(select_dedent), i(1) },
      }
    end
    return s(snip_args, snip_nodes, {
      stored = stored,
      condition = opts.condition,
      show_condition = opts.show_condition,
    })
  end
end

local jinja_statement = jinja_statement_generator(false, false)
local jinja_inline_statement = jinja_statement_generator(false, true)
local jinja_block = jinja_statement_generator(true, false)
local jinja_inline_block = jinja_statement_generator(true, true)

for statement, opts in pairs({
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
}) do
  local snip_fun = opts.block ~= false and jinja_block or jinja_statement
  local snip_opts = {
    trig = statement,
    dscr = opts.dscr or statement,
  }
  opts.condition = expand_conds.is_line_beginning
  opts.show_condition = show_conds.is_line_beginning()
  table.insert(snippets, snip_fun(vim.deepcopy(snip_opts), vim.deepcopy(opts.nodes), opts))
  if opts.inline ~= false then
    snip_fun = opts.block ~= false and jinja_inline_block or jinja_inline_statement
    snip_opts.wordTrig = false
    opts.condition = nil
    opts.show_condition = show_conds.is_not_line_beginning()
    table.insert(snippets, snip_fun(snip_opts, opts.nodes, opts))
  end
end

table.insert(
  snippets,
  s({ trig = "set", dscr = "Variable assignment" }, {
    cr(1, {
      {
        d(1, block_start),
        t("set "),
        r(2, 1, i(1, "var")),
        t(" = "),
        r(3, 2, i(1, "value")),
        t(" %}"),
      },
      {
        d(1, block_start),
        t("set "),
        r(2, 1),
        t({ " %}", "" }),
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

-- Filters
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
  if nodes then
    local filter_start = t(filter .. "(")
    if type(nodes) == "table" then
      if getmetatable(nodes) then
        nodes = { filter_start, nodes, t(")") }
      else
        table.insert(nodes, 1, filter_start)
        table.insert(nodes, t(")"))
      end
    else
      nodes = { filter_start, i(1), t(")") }
    end
  else
    nodes = t(filter)
  end
  table.insert(
    snippets,
    s({ trig = filter, dscr = "`" .. filter .. "` filter" }, nodes, {
      condition = expand_conds.is_after("|%s*"),
      show_condition = show_conds.is_after("|%s*"),
    })
  )
end

return snippets
