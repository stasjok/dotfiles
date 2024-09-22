local jinja_utils = {}

---Returns `true` if one of the `strings` are found in current file path
---@param strings string|string[]
---@return boolean
local function match_file_path(strings)
  if type(strings) == "string" then
    strings = { strings }
  end
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
  return vim.bo.filetype == "salt" or match_file_path({ "salt", "formula" })
end

---Returns `true` if current jinja file is for Ansible
---@return boolean
local function is_ansible()
  return vim.bo.filetype == "yaml.ansible" or match_file_path({ "ansible", "role" })
end

-- Flags to avoid setting queries twice
local is_jinja_query_set = false
local is_yaml_query_set = false

--- Set `ft_func` jinja2 query
local function set_jinja_query()
  if not is_jinja_query_set then
    is_jinja_query_set = true

    vim.treesitter.query.set(
      "jinja2",
      "ft_func",
      [[
        (jinja_stuff) @jinja
        (text) @text
      ]]
    )
  end
end

--- Set `ft_func` yaml query
local function set_yaml_query()
  if not is_yaml_query_set then
    is_yaml_query_set = true

    vim.treesitter.query.set(
      "yaml",
      "ft_func",
      [[
        (block_mapping_pair
          key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
          value: (flow_node [
            (plain_scalar (string_scalar))
            (double_quote_scalar)
            (single_quote_scalar)
          ] @value))

        (block_mapping_pair
          key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
          value: (block_node
            (block_scalar) @value))

        (block_mapping_pair
          key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
          value: (block_node
            (block_sequence
              (block_sequence_item
                (flow_node [
                  (plain_scalar (string_scalar))
                  (double_quote_scalar)
                  (single_quote_scalar)
                ] @value)))))

        (block_mapping_pair
          key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
          value: (block_node
            (block_sequence
              (block_sequence_item
                (block_node
                  (block_scalar) @value)))))

        (block_mapping_pair
          key: (flow_node) @key (#any-of? @key "when" "that" "var")
          value: (flow_node [
            (plain_scalar (string_scalar))
            (double_quote_scalar)
            (single_quote_scalar)
          ] @jinja))

        (block_mapping_pair
          key: (flow_node) @key (#any-of? @key "when" "that" "var")
          value: (block_node
            (block_scalar) @jinja))

        (block_mapping_pair
          key: (flow_node) @key (#any-of? @key "when" "that" "var")
          value: (block_node
            (block_sequence
              (block_sequence_item
                (flow_node [
                  (plain_scalar (string_scalar))
                  (double_quote_scalar)
                  (single_quote_scalar)
                ] @jinja)))))

        (block_mapping_pair
          key: (flow_node) @key (#any-of? @key "when" "that" "var")
          value: (block_node
            (block_sequence
              (block_sequence_item
                (block_node
                  (block_scalar) @jinja)))))
      ]]
    )
  end
end

---Returns LuaSnip `ft_func` for jinja or salt filetypes
---@param ft "jinja" | "salt" | "ansible" Filetype for `ft_func`
---@return fun(): string[]
function jinja_utils.jinja_ft_func(ft)
  local get_captures_at_cursor = require("treesitter.utils").get_captures_at_cursor
  local get_node_text_before_cursor = require("treesitter.utils").get_node_text_before_cursor

  -- List of jinja filters filetypes
  local filters_filetypes = setmetatable({
    salt = { "jinja_filters", "salt_filters" },
    ansible = { "jinja_filters", "ansible_filters" },
  }, {
    __index = function(tbl)
      if is_salt() then
        return rawget(tbl, "salt")
      elseif is_ansible() then
        return rawget(tbl, "ansible")
      else
        return { "jinja_filters" }
      end
    end,
  })

  -- List of jinja tests filetypes
  local tests_filetypes = setmetatable({
    salt = { "jinja_tests", "salt_tests" },
    ansible = { "jinja_tests", "ansible_tests" },
  }, {
    __index = function(tbl)
      if is_salt() then
        return rawget(tbl, "salt")
      elseif is_ansible() then
        return rawget(tbl, "ansible")
      else
        return { "jinja_tests" }
      end
    end,
  })

  -- List of jinja statements filetypes
  local statements_filetypes = setmetatable({
    salt = { "jinja_statements", "salt_statements" },
    ansible = { "jinja_statements" },
  }, {
    __index = function(tbl)
      if is_salt() then
        return rawget(tbl, "salt")
      elseif is_ansible() then
        return rawget(tbl, "ansible")
      else
        return { "jinja_statements" }
      end
    end,
  })

  -- List of jinja stuff filetypes
  local jinja_stuff_filetypes = setmetatable({
    salt = { "jinja_stuff", "salt_jinja_stuff" },
    ansible = { "jinja_stuff", "ansible_jinja_stuff" },
  }, {
    __index = function(tbl)
      if is_salt() then
        return rawget(tbl, "salt")
      elseif is_ansible() then
        return rawget(tbl, "ansible")
      else
        return { "jinja_stuff" }
      end
    end,
  })

  ---Return filetypes in jinja context
  ---@param text_to_cursor string
  ---@return string[]
  local function jinja_filetypes(text_to_cursor)
    if text_to_cursor:find("|%s*[%w_]*$", -40) then
      return filters_filetypes[ft]
    elseif text_to_cursor:find("is%s+[%w_]*$", -40) then
      return tests_filetypes[ft]
    elseif text_to_cursor:find("is%s+not%s+[%w_]*$", -40) then
      return tests_filetypes[ft]
    else
      return jinja_stuff_filetypes[ft]
    end
  end

  local ft_funcs = {
    jinja = function()
      set_jinja_query()

      local filetypes = {}
      local captures = get_captures_at_cursor("ft_func", 0, "jinja2")
      for _, capture in ipairs(captures) do
        if capture[1] == "jinja" then
          local text = get_node_text_before_cursor(capture[2], 0)
          vim.list_extend(filetypes, jinja_filetypes(text))
        elseif capture[1] == "text" then
          vim.list_extend(filetypes, statements_filetypes[ft])
        end
      end
      table.insert(filetypes, ft)
      return filetypes
    end,
    ansible = function()
      set_yaml_query()
      set_jinja_query()

      local filetypes = {}
      local captures = get_captures_at_cursor("ft_func", 0, "yaml")
      for _, capture in ipairs(captures) do
        if capture[1] == "value" then
          local node_text = vim.treesitter.get_node_text(capture[2], 0)
          local jinja_captures = get_captures_at_cursor("ft_func", 0, "jinja2", capture[2])
          for _, jinja_capture in ipairs(jinja_captures) do
            if jinja_capture[1] == "jinja" then
              local text =
                get_node_text_before_cursor(jinja_capture[2], node_text, jinja_capture[3])
              vim.list_extend(filetypes, jinja_filetypes(text))
            elseif jinja_capture[1] == "text" then
              vim.list_extend(filetypes, statements_filetypes[ft])
            end
          end
        elseif capture[1] == "jinja" then
          local text = get_node_text_before_cursor(capture[2], 0)
          vim.list_extend(filetypes, jinja_filetypes(text))
        end
        table.insert(filetypes, "jinja")
      end
      table.insert(filetypes, ft)
      return filetypes
    end,
  }
  ft_funcs.salt = ft_funcs.jinja

  return ft_funcs[ft]
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
function jinja_utils.block_start()
  local sn = require("luasnip.nodes.snippet").SN
  local t = require("luasnip.nodes.textNode").T
  local i = require("luasnip.nodes.insertNode").I
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
    local s = require("luasnip.nodes.snippet").S
    local t = require("luasnip.nodes.textNode").T
    local i = require("luasnip.nodes.insertNode").I
    local r = require("luasnip.nodes.restoreNode").R
    local f = require("luasnip.nodes.functionNode").F
    local d = require("luasnip.nodes.dynamicNode").D
    local rep = require("luasnip.extras").rep
    local l = require("luasnip.extras").lambda
    local p = require("luasnip.extras").partial
    local cr = require("snippets.nodes").cr
    local wn = require("snippets.nodes").wrapped_nodes
    local select_dedent = require("snippets.functions").select_dedent
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
  local expand_conds = require("snippets.expand_conditions")
  local show_conds = require("snippets.show_conditions")
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
  local t = require("luasnip.nodes.textNode").T
  local i = require("luasnip.nodes.insertNode").I
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
  local s = require("luasnip.nodes.snippet").S
  local snippets = {}
  for trig, opts in pairs(filters) do
    local dscr = opts.dscr or trig
    local nodes = jinja_nodes_for_filter(trig, opts.nodes)
    table.insert(snippets, s({ trig = trig, dscr = dscr }, nodes))
  end
  return snippets
end

return jinja_utils
