local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

require("nvim-autopairs").setup({
  fast_wrap = {},
})

-- Fix basic rules
for _, rule in ipairs(npairs.config.rules) do
  if rule.start_pair == "'" and rule.not_filetypes then
    -- Disable '' in nix
    table.insert(rule.not_filetypes, "nix")
  end
end

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

local jinja_filetypes = { "jinja", "jinja2", "yaml.ansible", "sls" }

-- Add spaces between parentheses
-- https://github.com/windwp/nvim-autopairs/issues/78
-- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules/425d8b096433b1329808797ff78f3acf23bc438f
npairs.add_rules({
  Rule(" ", " ")
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ "()", "{}", "[]" }, pair)
    end, nil)
    :with_move(cond.none())
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local context = opts.line:sub(col - 2, col + 1)
      return vim.tbl_contains({ "(  )", "{  }", "[  ]" }, context)
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
  -- Nix
  Rule("=", ";", "nix")
    :with_pair(not_in_comment(), nil)
    :with_pair(ts_conds.is_not_ts_node({ "source", "string", "indented_string" }), nil)
    :with_move(char_matches_end_pair),
  Rule("'", "'", "nix")
    :with_pair(cond.not_before_regex("[^%s]"), nil)
    :with_pair(cond.not_after_regex(npairs.config.ignored_next_char), nil)
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
      return vim.tbl_contains({ "{%%}", "{##}", "%-%}", "#-#}" }, pair)
    end, nil)
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local context = opts.line:sub(col - 3, col + 2)
      return vim.tbl_contains({ "{%  %}", "{#  #}", "%-  %}", "#-  #}" }, context)
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
})
