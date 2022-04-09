local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")

require("nvim-autopairs").setup({
  fast_wrap = {},
})

-- Add spaces between parentheses
-- https://github.com/windwp/nvim-autopairs/issues/78
-- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules/425d8b096433b1329808797ff78f3acf23bc438f
npairs.add_rules({
  Rule(" ", " ")
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ "()", "{}", "[]" }, pair)
    end)
    :with_move(cond.none())
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local context = opts.line:sub(col - 2, col + 1)
      return vim.tbl_contains({ "(  )", "{  }", "[  ]" }, context)
    end),
  Rule("", " )")
    :with_pair(cond.none())
    :with_move(function(opts)
      return opts.char == ")"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key(")"),
  Rule("", " }")
    :with_pair(cond.none())
    :with_move(function(opts)
      return opts.char == "}"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("}"),
  Rule("", " ]")
    :with_pair(cond.none())
    :with_move(function(opts)
      return opts.char == "]"
    end)
    :with_cr(cond.none())
    :with_del(cond.none())
    :use_key("]"),
})
