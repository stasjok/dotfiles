local s = require("luasnip.nodes.snippet").S
local sn = require("luasnip.nodes.snippet").SN
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C
local d = require("luasnip.nodes.dynamicNode").D
local r = require("luasnip.nodes.restoreNode").R
local m = require("luasnip.extras").match
local fmt = require("luasnip.extras.fmt").fmt
local cr = require("snippets.nodes").cr

local function fmte(str, nodes)
  return fmt(str, nodes, { trim_empty = false, dedent = false })
end

return {
  -- let
  --   $1
  -- in
  s(
    { trig = "let", dscr = "A let-expression" },
    cr(1, {
      fmte("let\n\t{}\nin", r(1, 1, i(1))),
      fmte("let {} in", r(1, 1)),
    })
  ),
  -- inherit () ;
  s(
    { trig = "inherit", dscr = "Inheriting attributes" },
    c(1, {
      fmte("inherit {};", r(1, 1, i(nil, "attr"))),
      fmte("inherit ({}) {};", { i(1, "src-set"), r(2, 1) }),
    })
  ),
  -- builtins.fetchTree
  s({ trig = "fetchTree", dscr = "Fetch a source tree" }, {
    t({ "fetchTree {", '\ttype = "' }),
    c(1, {
      t("github"),
      t("git"),
      t("tarball"),
      t("sourcehut"),
      t("mercurial"),
    }),
    t('";'),
    d(2, function(args)
      local function opts_nodes(opts, idx)
        local nodes = {}
        for index, arg in ipairs(opts) do
          vim.list_extend(
            nodes,
            { t({ "", "\t" .. arg .. ' = "' }), i(idx + index - 1, arg), t('";') }
          )
        end
        return nodes
      end
      local function rev_or_ref(index)
        return cr(index, {
          {
            t({ "", "\t" }),
            m(1, function(margs)
              return #margs[1][1] == 40
            end, "rev", "ref"),
            t(' = "'),
            r(1, "ref", i(nil, "rev-or-ref")),
            t('";'),
          },
          {
            t({ "", '\tref = "' }),
            r(1, "ref"),
            t({ '";', '\trev = "' }),
            i(2, "rev"),
            t('";'),
          },
        })
      end
      local nodes = {}
      local idx = 1
      if args[1][1] == "github" or args[1][1] == "sourcehut" then
        vim.list_extend(nodes, opts_nodes({ "owner", "repo" }, idx))
        idx = idx + 2
        table.insert(nodes, rev_or_ref(idx))
        idx = idx + 1
      elseif args[1][1] == "git" or args[1][1] == "mercurial" then
        vim.list_extend(nodes, opts_nodes({ "url" }, idx))
        idx = idx + 1
        table.insert(nodes, rev_or_ref(idx))
        idx = idx + 1
      elseif args[1][1] == "tarball" then
        vim.list_extend(nodes, opts_nodes({ "url" }, idx))
        idx = idx + 1
      end
      return sn(nil, nodes)
    end, 1),
    t({ "", '\tnarHash = "' }),
    i(3, "sha256"),
    t({ '";', "}" }),
  }, {
    show_condition = function()
      local pos = vim.api.nvim_win_get_cursor(0)[2]
      local line_to_cursor = vim.api.nvim_get_current_line():sub(1, pos)
      return line_to_cursor:find("^%s*%a+%s*=%s*%a*$") or line_to_cursor:find("builtins%.%a*$")
    end,
  }),
}
