local map_expr = require("map").map_expr
local replace_termcodes = require("map").replace_termcodes
local completion_kinds = require("plugins.lspconfig.utils").completion_kinds

local cmp = {}

local completion_menu_map = {
  luasnip = "[Snip]",
  nvim_lsp = "[LSP]",
  path = "[Path]",
  buffer = "[Buf]",
}

local function format_vim_item(entry, vim_item)
  -- Change completion kinds
  vim_item.kind = completion_kinds[vim_item.kind] or vim_item.kind
  -- Change menu type
  vim_item.menu = completion_menu_map[entry.source.name] or string.format("[%s]", entry.source.name)
  return vim_item
end

function cmp.config()
  ---@diagnostic disable-next-line: redefined-local
  local cmp = require("cmp")
  local mapping = require("cmp.mapping")

  cmp.setup({
    sources = {
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
    },
    confirmation = {
      default_behavior = cmp.ConfirmBehavior.Replace,
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    formatting = {
      format = format_vim_item,
    },
    mapping = {
      ["<C-Y>"] = function()
        if vim.fn.pumvisible() == 1 then
          cmp.close()
          -- Without extra key some keys like <C-N> / <C-P> doesn't work
          vim.api.nvim_feedkeys(replace_termcodes("<C-Y>"), "n", false)
        else
          cmp.complete()
        end
      end,
      ["<C-E>"] = function()
        if vim.fn.pumvisible() == 1 then
          cmp.abort()
        end
      end,
      ["<CR>"] = mapping.confirm(),
      ["<M-CR>"] = mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
      }),
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
