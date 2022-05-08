local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

local function char_matches_end_pair(opts)
  return opts.char == opts.next_char:sub(1, 1)
end

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
  Rule("= ", ";", "nix"):with_move(char_matches_end_pair),
  Rule("'", "'", "nix")
    :with_pair(ts_conds.is_ts_node("indented_string"), nil)
    :with_pair(cond.not_after_regex(npairs.config.ignored_next_char), nil)
    :with_move(char_matches_end_pair),
  Rule("''", "''", "nix")
    :with_pair(ts_conds.is_not_ts_node({ "comment", "string", "indented_string" }), nil)
    :with_pair(cond.not_before_text("''"), nil)
    :with_move(char_matches_end_pair),
})
