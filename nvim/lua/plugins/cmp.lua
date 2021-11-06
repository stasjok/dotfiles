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

---Returns a list of bufnrs suitable for cmp_buffer completion
---@return number[]
local function get_bufnrs()
  -- Skip buffers with more lines than
  local max_buf_size = 1000
  local all_bufnrs = vim.api.nvim_list_bufs()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local bufnrs = {}
  for _, bufnr in ipairs(all_bufnrs) do
    if
      vim.api.nvim_buf_is_loaded(bufnr)
        and vim.api.nvim_buf_line_count(bufnr) <= max_buf_size
      or bufnr == current_bufnr
    then
      table.insert(bufnrs, bufnr)
    end
  end
  return bufnrs
end

function cmp.config()
  ---@diagnostic disable-next-line: redefined-local
  local cmp = require("cmp")
  local mapping = cmp.mapping

  cmp.setup({
    sources = {
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "path" },
      {
        name = "buffer",
        opts = {
          keyword_pattern = [[[a-zA-ZА-яЁё_][0-9a-zA-ZА-яЁё_-]\+]],
          get_bufnrs = get_bufnrs,
        },
      },
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
