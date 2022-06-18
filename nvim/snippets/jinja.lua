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
    opts = opts or {}
    local statement = type(snip_args) == "string" and snip_args or snip_args.trig
    -- local end_statement = opts.end_statement or ("end" .. statement)
    local end_statement = opts.end_statement or ("end" .. statement)
    if not opts.no_space and type(nodes) == "table" and not vim.tbl_isempty(nodes) then
      statement = statement .. " "
    end
    local snip_nodes = {
      t("{% " .. statement),
      r(1, 1),
      t(" %}"),
    }
    if block then
      vim.list_extend(snip_nodes, {
        r(2, 2),
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
        r(2, 1),
        end_block,
      }
      if block then
        vim.list_extend(snip_nodes, {
          t({ "", "" }),
          r(3, 2),
          t({ "", "" }),
          repeat_block,
          t(end_statement .. " %}"),
        })
      end
      snip_nodes = {
        cr(1, {
          snip_nodes,
          inline_nodes,
        }),
      }
    end
    if opts.append_newline and not inline then
      table.insert(snip_nodes, t({ "", "" }))
    end
    local stored = { nodes or {} }
    if block then
      table.insert(stored, { f(select_dedent), i(1) })
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
  block = {
    dscr = "Block tag",
    nodes = i(1, "tag"),
  },
  raw = {
    dscr = "Raw block",
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
  snip_fun = opts.block ~= false and jinja_inline_block or jinja_inline_statement
  snip_opts.wordTrig = false
  opts.condition = nil
  opts.show_condition = show_conds.is_not_line_beginning()
  table.insert(snippets, snip_fun(snip_opts, opts.nodes, opts))
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

return snippets
