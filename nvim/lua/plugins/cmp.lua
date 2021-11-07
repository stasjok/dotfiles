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
  local result = {}
  local cur_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()
  for i = 1, #all_bufs do
    local buf = all_bufs[i]
    if
      vim.api.nvim_buf_get_option(buf, "buflisted")
        and vim.api.nvim_buf_line_count(buf) <= max_buf_size
      or buf == cur_buf
    then
      table.insert(result, buf)
    end
  end
  return result
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
      ["<Tab>"] = mapping({
        i = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end,
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end,
      }),
      ["<S-Tab>"] = mapping({
        i = function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            vim.api.nvim_feedkeys(replace_termcodes("<C-D>"), "n", false)
          end
        end,
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          end
        end,
      }),
      ["<CR>"] = mapping.confirm(),
      ["<M-CR>"] = mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
      }),
      ["<C-Y>"] = mapping(function()
        if cmp.visible() then
          cmp.confirm()
        else
          cmp.complete()
        end
      end, {
        "i",
        "c",
      }),
      ["<C-E>"] = mapping(function()
        if cmp.visible() then
          cmp.abort()
        end
      end, {
        "i",
        "c",
      }),
      ["<C-n>"] = mapping({
        i = mapping.select_next_item(),
        c = function(fallback)
          cmp.close()
          vim.schedule(cmp.suspend())
          fallback()
        end,
      }),
      ["<C-p>"] = mapping({
        i = mapping.select_prev_item(),
        c = function(fallback)
          cmp.close()
          vim.schedule(cmp.suspend())
          fallback()
        end,
      }),
      ["<M-d>"] = mapping(mapping.scroll_docs(8), { "i", "c" }),
      ["<M-u>"] = mapping(mapping.scroll_docs(-8), { "i", "c" }),
    },
  })

  cmp.setup.cmdline(":", {
    sources = {
      { name = "cmdline" },
      { name = "path" },
    },
  })

  -- Automatically insert brackets for functions and methods
  cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
end

return cmp
