local luasnip = require("luasnip")
local map = vim.keymap.set
local s = luasnip.snippet
local i = luasnip.insert_node
local c = luasnip.choice_node

-- Configuration
luasnip.config.setup({
  updateevents = "TextChanged,TextChangedI",
  store_selection_keys = "<C-H>",
  snip_env = nil,
  parser_nested_assembler = function(pos, snip)
    snip.pos = nil
    -- Have to create temporary snippet, see: https://github.com/L3MON4D3/LuaSnip/issues/400
    local snip_text = s("", snip:copy()):get_static_text()
    return c(pos, { i(nil, snip_text), snip })
  end,
})

-- Filetypes
luasnip.filetype_extend("sls", { "jinja" })
luasnip.filetype_extend("ansible", { "jinja", "jinja2" })
luasnip.filetype_extend("jinja2", { "jinja" })

-- Mapping functions
local function luasnip_jump(n)
  return function()
    luasnip.jump(n)
  end
end

local function luasnip_change_choice(n)
  return function()
    if luasnip.choice_active() then
      luasnip.change_choice(n)
    end
  end
end

-- Mappings
map("i", "<C-H>", luasnip.expand)
map({ "i", "s", "n" }, "<C-J>", luasnip_jump(1))
map({ "i", "s", "n" }, "<C-K>", luasnip_jump(-1))
map({ "i", "s", "n" }, "<C-L>", luasnip_change_choice(1))
map("s", "<BS>", "<C-O>c")
map("s", "<Del>", "<C-O>c")

-- Load snippets
luasnip.cleanup()
local opts = {
  paths = vim.api.nvim_get_runtime_file("snippets", true),
}
require("luasnip.loaders.from_vscode").lazy_load(opts)
require("luasnip.loaders.from_snipmate").lazy_load(opts)
require("luasnip.loaders.from_lua").lazy_load(opts)
