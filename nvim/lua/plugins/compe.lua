local map = require("map").map
local map_expr = require("map").map_expr

local compe = {}

function compe.config()
  require("compe").setup({
    source = {
      luasnip = true,
      nvim_lsp = true,
      path = true,
      buffer = true,
    },
  })
  vim.opt.completeopt = { "menuone", "noselect" }

  -- Mappings
  map_expr("i", "<C-Y>", "pumvisible() ? compe#confirm() : compe#complete()")
  map_expr("i", "<Tab>", "pumvisible() ? '<C-N>' : '<Tab>'")
  map_expr("i", "<S-Tab>", "pumvisible() ? '<C-P>' : '<C-D>'")
  -- without extra <C-E>, keys like <C-N>/<C-P> doesn't work
  map("i", "<C-E>", "<Cmd>lua require('compe')._close()<CR><C-E>")
  map_expr("i", "<M-d>", "compe#scroll({ 'delta': +8 })")
  map_expr("i", "<M-u>", "compe#scroll({ 'delta': -8 })")
end

return compe
