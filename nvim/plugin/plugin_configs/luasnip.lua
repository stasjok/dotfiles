local map = require("map").map
local map_expr = require("map").map_expr
local replace_termcodes_wrap = require("map").replace_termcodes_wrap

local function change_choice()
  if require("luasnip").choice_active() then
    return "<Cmd>lua require('luasnip').change_choice(1)<CR>"
  else
    return "<Ignore>"
  end
end

require("luasnip.config").setup({
  updateevents = "TextChanged,TextChangedI",
  store_selection_keys = "<C-H>",
  parser_nested_assembler = function(pos, snip)
    local i = require("luasnip").insert_node
    local c = require("luasnip").choice_node
    local snip_text = snip:get_static_text()
    snip.pos = nil
    return c(pos, { i(nil, snip_text), snip })
  end,
})

-- Mappings
map("i", "<C-H>", "<Cmd>lua require('luasnip').expand()<CR>")
map({ "i", "s", "n" }, "<C-J>", "<Cmd>lua require('luasnip').jump(1)<CR>")
map({ "i", "s", "n" }, "<C-K>", "<Cmd>lua require('luasnip').jump(-1)<CR>")
map_expr({ "i", "s", "n" }, "<C-L>", replace_termcodes_wrap(change_choice))
map("s", "<BS>", "<C-O>c")
map("s", "<Del>", "<C-O>c")

-- Load snippets
local opts = {
  paths = vim.api.nvim_get_runtime_file("snippets", true),
}
require("luasnip.loaders.from_vscode").lazy_load(opts)
require("luasnip.loaders.from_snipmate").lazy_load(opts)
require("luasnip.loaders.from_lua").lazy_load(opts)
