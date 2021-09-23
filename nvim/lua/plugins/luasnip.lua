local map = require("map").map
local map_expr = require("map").map_expr
local replace_termcodes_wrap = require("map").replace_termcodes_wrap

local luasnip = {}

local function change_choice()
  if require("luasnip").choice_active() then
    return "<Cmd>lua require('luasnip').change_choice(1)<CR>"
  else
    return "<Ignore>"
  end
end

function luasnip.config()
  require("luasnip.config").setup({
    updateevents = "TextChanged,TextChangedI",
    store_selection_keys = "<C-H>",
  })

  -- Mappings
  map("i", "<C-H>", "<Cmd>lua require('luasnip').expand()<CR>")
  map({ "i", "s", "n" }, "<C-J>", "<Cmd>lua require('luasnip').jump(1)<CR>")
  map({ "i", "s", "n" }, "<C-K>", "<Cmd>lua require('luasnip').jump(-1)<CR>")
  map_expr({ "i", "s", "n" }, "<C-L>", replace_termcodes_wrap(change_choice))
  map("s", "<BS>", "<C-O>c")
  map("s", "<Del>", "<C-O>c")

  -- Load snippets
  vim.api.nvim_command("runtime snippets/snippets.lua")
end

return luasnip
