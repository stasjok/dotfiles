local s = require("luasnip.nodes.snippet").S
local sn = require("luasnip.nodes.snippet").SN
local t = require("luasnip.nodes.textNode").T
local f = require("luasnip.nodes.functionNode").F
local i = require("luasnip.nodes.insertNode").I
local d = require("luasnip.nodes.dynamicNode").D
local r = require("luasnip.nodes.restoreNode").R
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local cr = require("snippets.nodes").cr
local wn = require("snippets.nodes").wrapped_nodes
local select_dedent = require("snippets.functions").select_dedent

local jinja_utils = {}

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
function jinja_utils.is_salt()
  return vim.bo.filetype == "sls" or match_file_path({ "salt", "formula" })
end

---Returns `true` if current jinja file is for Ansible
---@return boolean
function jinja_utils.is_ansible()
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
local get_trim_block = get_option("jinja_trim_blocks", jinja_utils.is_ansible)
---Is `lstrip_blocks` enabled?
local get_lstrip_blocks = get_option("jinja_lstrip_blocks", false)

---A function for dynamicNode that returns jinja block start
---@return table
function jinja_utils.block_start()
  local trim_blocks, lstrip_blocks = get_trim_block(), get_lstrip_blocks()
  local block = trim_blocks and "{% " or "{%- "
  local nodes = { t(block) }
  if not lstrip_blocks then
    table.insert(nodes, i(1))
  end
  return sn(nil, nodes)
end

---Returns a function for functionNode that returns ` %}` or ` -%}` based on `trim_end_block` and `b:jinja_trim_blocks`
---@param trim_end_block boolean Is trimming of end block needed?
---@return function
function jinja_utils.block_end(trim_end_block)
  return function()
    return (trim_end_block and not get_trim_block()) and " -%}" or " %}"
  end
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
        end_block = p(jinja_utils.block_end(true))
        repeat_block = l(l._1:gsub("^{%%  ?", "{%%- "), 1)
      else
        end_block = t(" %}")
        repeat_block = rep(1)
      end
      snip_nodes = {
        d(1, jinja_utils.block_start),
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

jinja_utils.jinja_statement = jinja_statement_generator(false, false)
jinja_utils.jinja_inline_statement = jinja_statement_generator(false, true)
jinja_utils.jinja_block = jinja_statement_generator(true, false)
jinja_utils.jinja_inline_block = jinja_statement_generator(true, true)

---Prepend nodes for jinja filter or test
---@param name string Name of the filter or test
---@param nodes boolean | table If `false`, returns `name`, if `true` returns `name($1)`, if `table` returns `name($nodes)`
---@return table #Nodes
local function jinja_nodes_for_filter(name, nodes)
  if nodes then
    local filter_start = t(name .. "(")
    if type(nodes) == "table" then
      if getmetatable(nodes) then
        -- Single node
        nodes = { filter_start, nodes, t(")") }
      else
        -- List of nodes
        table.insert(nodes, 1, filter_start)
        table.insert(nodes, t(")"))
      end
    else
      -- True
      nodes = { filter_start, i(1), t(")") }
    end
  else
    -- False or nil
    nodes = t(name)
  end
  return nodes
end

---Returns jinja filter or test snippets
---@param filters {dscr?: string, nodes?: table|boolean} Filter or test definitions
---@return table
function jinja_utils.jinja_filter_snippets(filters)
  local snippets = {}
  for trig, opts in pairs(filters) do
    local dscr = opts.dscr or trig
    local nodes = jinja_nodes_for_filter(trig, opts.nodes)
    table.insert(snippets, s({ trig = trig, dscr = dscr }, nodes))
  end
  return snippets
end

return jinja_utils
