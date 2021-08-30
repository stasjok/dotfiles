local map_expr = require("map").map_expr
local replace_termcodes = require("map").replace_termcodes

local cmp = {}

function cmp.config()
  local mapping = require("cmp.mapping")

  require("cmp").setup({
    sources = {
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = {
      ["<C-Y>"] = function()
        if vim.fn.pumvisible() == 1 then
          require("cmp").close()
          -- Without extra key some keys like <C-N> / <C-P> doesn't work
          vim.api.nvim_feedkeys(replace_termcodes("<C-Y>"), "n", false)
        else
          require("cmp").complete()
        end
      end,
      ["<C-E>"] = function()
        if vim.fn.pumvisible() == 1 then
          require("cmp").abort()
        end
      end,
      ["<CR>"] = mapping.confirm(),
      ["<M-d>"] = mapping.scroll_docs(8),
      ["<M-u>"] = mapping.scroll_docs(-8),
    },
  })

  -- Automatically insert brackets for functions and methods
  require("nvim-autopairs.completion.cmp").setup({
    map_complete = true,
  })

  -- Mappings
  map_expr("i", "<Tab>", "pumvisible() ? '<C-N>' : '<Tab>'")
  map_expr("i", "<S-Tab>", "pumvisible() ? '<C-P>' : '<C-D>'")
end

return cmp
