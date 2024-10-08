local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")
local completion_cmp = require("nvim-autopairs.completion.cmp")

-- Condition opts types

---Condition options for `can_pair`, `can_move`
---@class cond_opts_pair
---@field ts_node string|string[]|nil
---@field text string
---@field rule Rule
---@field bufnr number
---@field col number
---@field char string
---@field line string
---@field prev_char string
---@field next_char string

---Condition options for `can_del`
---@class cond_opts_del
---@field ts_node string|string[]|nil
---@field bufnr number
---@field prev_char string
---@field next_char string
---@field line string

---Condition options for `can_cr`
---@class cond_opts_cr
---@field ts_node string|string[]|nil
---@field check_endwise_ts boolean
---@field rule Rule
---@field bufnr number
---@field col number
---@field line string
---@field prev_char string
---@field next_char string

---Check if entered character matches `end_pair`'s first char.
---@param opts cond_opts_pair
---@return boolean
local function char_matches_end_pair(opts)
  return opts.char == opts.next_char:sub(1, 1)
end

---Returns a simple function that checks if cursor is not in a single-line comment.
---@param comment_char? string Character used for comments. Default: `#`
---@return fun(opts: cond_opts_pair): false? #Autopairs condition
local function not_in_comment(comment_char)
  local comment = comment_char or "#"
  ---Check if cursor is in single-line comment.
  ---@param opts cond_opts_pair
  ---@return false? #Autopairs condition
  return function(opts)
    if opts.line:sub(1, opts.col):find(comment, 1, true) then
      return false
    end
  end
end

---A condition for Rust Generic Parameter <>
local function is_rust_generic_param(opts)
  local identifier = "[%w_]+"
  local str = opts.line:sub(1, opts.col - 1)
  if
    str:find(":%s*" .. identifier .. "%s*$") -- var: Type|
    or str:find(":%s*impl%s+" .. identifier .. "%s*$") -- var: impl Type|
    or str:find("->%s*" .. identifier .. "%s*$") -- f() -> Type|
    or str:find("->%s*impl%s+" .. identifier .. "%s*$") -- f() -> impl Type|
    or str:find("fn%s+" .. identifier .. "%s*$") -- fn fname|
    or str:find("struct%s+" .. identifier .. "%s*$") -- struct Name|
    or str:find("enum%s+" .. identifier .. "%s*$") -- enum Name|
    or str:find("impl%s*$") -- impl|
    or str:find("impl%s+" .. identifier .. "%s*$") -- impl Name|
    or str:find("impl%s*%b<>%s*" .. identifier .. "%s*$") -- impl<T> Name|
    or str:find("trait%s+" .. identifier .. "%s*$") -- trait Name|
    or str:find("type%s+" .. identifier .. "%s*$") -- type Name|
    or str:find("::%s*$") -- turbofish::|
  then
    return true
  end
  return false
end

--- A condition for Rust closure parameters
local function is_rust_closure(opts)
  local str = opts.line:sub(1, opts.col - 1)
  if
    str:find("move%s+$") -- move |
    or str:find("=%s*$") -- let statement: = |
    or str:find("[(,]%s*$") -- function parameters: (| or , |
  then
    return true
  else
    return false
  end
end

local jinja_filetypes = { "jinja", "jinja2", "yaml.ansible", "salt" }

-- Extra pairs
local pairs = {
  -- Add spaces between parentheses
  -- https://github.com/windwp/nvim-autopairs/issues/78
  -- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules/425d8b096433b1329808797ff78f3acf23bc438f
  Rule(" ", " ")
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.list_contains({ "()", "{}", "[]" }, pair)
    end, nil)
    :with_move(cond.none())
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local context = opts.line:sub(col - 2, col + 1)
      return vim.list_contains({ "(  )", "{  }", "[  ]" }, context)
    end),
  Rule("", " )")
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == ")"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key(")"),
  Rule("", " }")
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "}"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("}"),
  Rule("", " ]")
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "]"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("]"),

  -- Lua
  Rule("=", ",", "lua")
    :with_pair(cond.not_after_regex("%s?}", 2), nil)
    :with_pair(
      ts_conds.is_ts_node({ "table_constructor", "field", "bracket_index_expression" }),
      nil
    )
    :with_cr(cond.none())
    :with_move(char_matches_end_pair),

  -- Nix
  Rule("=", ";", "nix")
    :with_pair(not_in_comment(), nil)
    :with_pair(ts_conds.is_not_ts_node({ "source", "string", "indented_string" }), nil)
    :with_cr(cond.none())
    :with_move(char_matches_end_pair),
  Rule("'", "'", "nix")
    :with_pair(cond.not_before_regex("[^%s]"), nil)
    :with_pair(cond.not_after_regex([=[[%w%%%'%[%"%.%`%$]]=]), nil) -- Upstream default
    :with_pair(ts_conds.is_ts_node("indented_string"), nil)
    :with_move(cond.not_after_text("''"))
    :with_move(char_matches_end_pair),
  Rule("''", "''", "nix")
    :with_pair(not_in_comment(), nil)
    :with_pair(ts_conds.is_not_ts_node({ "source", "string", "indented_string" }), nil)
    :with_pair(cond.not_before_text("''"), nil)
    :with_move(char_matches_end_pair),

  -- Jinja
  Rule("%", "%", jinja_filetypes):with_pair(function(opts)
    return opts.line:sub(opts.col - 1, opts.col) == "{}"
  end, nil),
  Rule("#", "#", jinja_filetypes):with_pair(function(opts)
    return opts.line:sub(opts.col - 1, opts.col) == "{}"
  end, nil),
  Rule(" ", " ", jinja_filetypes)
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 2, opts.col + 1)
      return vim.list_contains({ "{%%}", "{##}", "%-%}", "{-}}", "#-#}" }, pair)
    end, nil)
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local context = opts.line:sub(col - 3, col + 2)
      return vim.list_contains({ "{%  %}", "{#  #}", "%-  %}", "{-  }}", "#-  #}" }, context)
    end),
  Rule("", "%}", jinja_filetypes)
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "%"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("%"),
  Rule("", "#}", jinja_filetypes)
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "#"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("#"),
  Rule("", " %}", jinja_filetypes)
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "%"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("%"),
  Rule("", " #}", jinja_filetypes)
    :with_pair(cond.none(), nil)
    :with_move(function(opts)
      return opts.char == "#"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("#"),

  -- Rust
  Rule("<", ">", "rust")
    :with_pair(is_rust_generic_param)
    :with_move(char_matches_end_pair)
    :with_cr(cond.none()),
  Rule("|", "|", "rust")
    :with_pair(is_rust_closure)
    :with_move(char_matches_end_pair)
    :with_cr(cond.none()),
  Rule("=", ";", "rust")
    :with_pair(function(opts)
      return (
        cond.before_regex("let%s+[^=]+$", 100)(opts)
        or cond.before_regex("type%s+[^=]+$", 100)(opts)
      ) and cond.after_regex("^%s*$", 10)(opts)
    end)
    :with_move(char_matches_end_pair)
    :with_cr(cond.none()),
}

-- Configuration
npairs.setup({
  enable_check_bracket_line = false,
  fast_wrap = {},
})

-- Fix basic rules
for _, rule in ipairs(npairs.config.rules) do
  if rule.start_pair == "'" and rule.not_filetypes then
    -- Disable '' in nix
    table.insert(rule.not_filetypes, "nix")
  end
end

-- Add pairs
npairs.add_rules(pairs)

-- Automatically insert brackets for functions and methods
local default_handler = completion_cmp.filetypes["*"]
local cmp = vim.F.npcall(require, "cmp")
if cmp then
  cmp.event:on(
    "confirm_done",
    completion_cmp.on_confirm_done({
      filetypes = {
        ["*"] = false,
        lua = default_handler,
        python = default_handler,
      },
    })
  )
end
