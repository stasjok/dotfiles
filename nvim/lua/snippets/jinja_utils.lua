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
local expand_conds = require("snippets.expand_conditions")
local show_conds = require("snippets.show_conditions")
local is_in_node_range = require("nvim-treesitter.ts_utils").is_in_node_range
local get_cursor_0 = require("utils").get_cursor_0
local get_string_parser = vim.treesitter.get_string_parser
local get_query = vim.treesitter.get_query
local get_node_text = vim.treesitter.get_node_text
local buf_get_offset = vim.api.nvim_buf_get_offset
local get_captures_at_cursor = require("treesitter.utils").get_captures_at_cursor
local get_node_text_before_cursor = require("treesitter.utils").get_node_text_before_cursor

local jinja_utils = {}

---Returns `true` if one of the `strings` are found in current file path
---@param strings string|string[]
---@return boolean
local function match_file_path(strings)
  strings = type(strings) == "table" and strings or { strings }
  ---@diagnostic disable-next-line: missing-parameter
  local path = vim.fn.expand("%:p:h") --[[@as string]]
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

-- List of jinja filters filetypes
local filters_filetypes = setmetatable({
  sls = { "jinja_filters", "salt_filters" },
  ansible = { "jinja_filters", "ansible_filters" },
}, {
  __index = function(tbl)
    if is_salt() then
      return rawget(tbl, "sls")
    elseif is_ansible() then
      return rawget(tbl, "ansible")
    else
      return { "jinja_filters" }
    end
  end,
})

-- List of jinja tests filetypes
local tests_filetypes = setmetatable({
  sls = { "jinja_tests", "salt_tests" },
  ansible = { "jinja_tests", "ansible_tests" },
}, {
  __index = function(tbl)
    if is_salt() then
      return rawget(tbl, "sls")
    elseif is_ansible() then
      return rawget(tbl, "ansible")
    else
      return { "jinja_tests" }
    end
  end,
})

-- List of jinja statements filetypes
local statements_filetypes = setmetatable({
  sls = { "jinja_statements", "salt_statements" },
  ansible = { "jinja_statements" },
}, {
  __index = function(tbl)
    if is_salt() then
      return rawget(tbl, "sls")
    elseif is_ansible() then
      return rawget(tbl, "ansible")
    else
      return { "jinja_statements" }
    end
  end,
})

---Returns LuaSnip `ft_func` for jinja or sls filetypes
---@param ft "jinja" | "sls" Filetype for `ft_func`
---@return fun(): string[]
function jinja_utils.jinja_ft_func(ft)
  local query_string = [[
    (jinja_stuff) @jinja
    (text) @text
  ]]
  vim.treesitter.set_query("jinja2", "ft_func", query_string)

  return function()
    local filetypes = {}
    local captures = get_captures_at_cursor(0, "ft_func", "jinja2")
    for _, capture in ipairs(captures) do
      if capture[1] == "jinja" then
        local text = get_node_text_before_cursor(capture[2], 0)
        if text:find("|%s*[%w_]*$", -40) then
          vim.list_extend(filetypes, filters_filetypes[ft])
        elseif text:find("is%s+[%w_]*$", -40) then
          vim.list_extend(filetypes, tests_filetypes[ft])
        end
      elseif capture[1] == "text" then
        vim.list_extend(filetypes, statements_filetypes[ft])
      end
    end
    table.insert(filetypes, ft)
    return filetypes
  end
end

---Returns cursor position relative to tree-sitter node
---@param node table
---@param row integer
---@param col integer
---@return integer row
---@return integer col
---@return integer byte_offset
local function get_cursor_relative_to_node(node, row, col)
  local start_row, start_col, start_byte = node:start() --[[@as integer, integer, integer]]
  if row < start_row or row == start_row and col < start_col then
    return 0, 0, 0
  elseif row == start_row then
    return 0, col - start_col, col - start_col
  else
    return row - start_row, col, buf_get_offset(0, row) - start_byte + col
  end
end

---Returns LuaSnip `ft_func` for ansible filetype
---@return fun(): string[]
function jinja_utils.ansible_ft_func()
  local query_string = [[
    (block_mapping_pair
      value: (flow_node [
        (plain_scalar (string_scalar))
        (double_quote_scalar)
        (single_quote_scalar)
      ] @value))

    (block_mapping_pair
      value: (block_node
        (block_scalar) @value))

    (block_sequence_item
      (flow_node [
        (plain_scalar (string_scalar))
        (double_quote_scalar)
        (single_quote_scalar)
      ] @value))

    (block_sequence_item
      (block_node
        (block_scalar) @value))
  ]]
  vim.treesitter.set_query("yaml", "ft_func", query_string)
  query_string = [[
    (jinja_stuff) @jinja
    (text) @text
  ]]
  vim.treesitter.set_query("jinja2", "ft_func", query_string)

  return function()
    local captures = get_captures_at_cursor(0, "ft_func", "yaml")
    local filetypes = {}
    for _, capture in ipairs(captures) do
      local node = capture[2]
      local node_text = get_node_text(node, 0)
      local row, col = get_cursor_0()
      local node_row, node_col, node_byte = get_cursor_relative_to_node(node, row, col)
      local parser = get_string_parser(node_text, "jinja2")
      ---@diagnostic disable-next-line: need-check-nil
      local root = parser:parse()[1]:root()
      local query = get_query("jinja2", "ft_func")
      for id, jinja_node in query:iter_captures(root, node_text, node_row, node_row + 1) do
        if is_in_node_range(jinja_node, node_row, node_col) then
          local jinja_capture = query.captures[id]
          if jinja_capture == "jinja" then
            local text = get_node_text_before_cursor(jinja_node, node_text, node_byte)
            if text:find("|%s*[%w_]*$", -40) then
              vim.list_extend(filetypes, filters_filetypes["ansible"])
            elseif text:find("is%s+[%w_]*$", -40) then
              vim.list_extend(filetypes, tests_filetypes["ansible"])
            end
          elseif jinja_capture == "text" then
            vim.list_extend(filetypes, statements_filetypes["ansible"])
          end
        end
      end
      table.insert(filetypes, "jinja")
    end
    table.insert(filetypes, "ansible")
    return filetypes
  end
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

---Returns jinja statement snippets
---@param statements {dscr?: string, nodes?: table|boolean, block?: boolean, inline?: boolean, no_space?: boolean, end_statement?: string, trim_block?: boolean, append_newline?:boolean} Statement definitions
---@return table
function jinja_utils.jinja_statement_snippets(statements)
  local snippets = {}
  for trig, opts in pairs(statements) do
    local snip_fun = opts.block ~= false and jinja_utils.jinja_block or jinja_utils.jinja_statement
    local snip_opts = {
      trig = trig,
      dscr = opts.dscr or trig,
    }
    opts.condition = expand_conds.is_line_beginning
    opts.show_condition = show_conds.is_line_beginning()
    table.insert(snippets, snip_fun(vim.deepcopy(snip_opts), vim.deepcopy(opts.nodes), opts))
    if opts.inline ~= false then
      snip_fun = opts.block ~= false and jinja_utils.jinja_inline_block
        or jinja_utils.jinja_inline_statement
      snip_opts.wordTrig = false
      opts.condition = nil
      opts.show_condition = show_conds.is_not_line_beginning()
      table.insert(snippets, snip_fun(snip_opts, opts.nodes, opts))
    end
  end
  return snippets
end

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
