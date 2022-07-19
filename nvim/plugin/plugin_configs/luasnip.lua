local luasnip = require("luasnip")
local s = luasnip.snippet
local i = luasnip.insert_node
local c = luasnip.choice_node
local on_the_fly = require("luasnip.extras.otf").on_the_fly
local extend_load_ft = require("luasnip.extras.filetype_functions").extend_load_ft
local jinja_ft_func = require("snippets.jinja_utils").jinja_ft_func
local ansible_ft_func = require("snippets.jinja_utils").ansible_ft_func
local map = vim.keymap.set

-- Filetypes
luasnip.filetype_set("sls", { "sls", "jinja" })

---@type fun(): string[] Returns a list of snippet filetypes for current cursor position
local ft_func = setmetatable({
  jinja = jinja_ft_func("jinja"),
  sls = jinja_ft_func("sls"),
  ansible = ansible_ft_func(),
}, {
  __call = function(tbl)
    local filetypes = {}
    for ft in vim.gsplit(vim.bo.filetype, ".", true) do
      for _, filetype in ipairs(tbl[ft] and tbl[ft]() or { ft }) do
        table.insert(filetypes, filetype)
      end
    end
    return filetypes
  end,
}) --[[@as function]]

-- Configuration
luasnip.config.setup({
  updateevents = "TextChanged,TextChangedI",
  region_check_events = "InsertEnter",
  store_selection_keys = "<C-H>",
  snip_env = nil,
  ft_func = ft_func,
  load_ft_func = extend_load_ft({
    jinja = {
      "jinja_statements",
      "jinja_filters",
      "jinja_tests",
      "salt_statements",
      "salt_filters",
      "salt_tests",
      "ansible_filters",
      "ansible_tests",
    },
    sls = {
      "jinja_statements",
      "jinja_filters",
      "jinja_tests",
      "salt_statements",
      "salt_filters",
      "salt_tests",
    },
    ansible = {
      "jinja_statements",
      "jinja_filters",
      "jinja_tests",
      "ansible_filters",
      "ansible_tests",
    },
  }),
  parser_nested_assembler = function(pos, snip)
    snip.pos = nil
    -- Have to create temporary snippet, see: https://github.com/L3MON4D3/LuaSnip/issues/400
    local snip_text = s("", snip:copy()):get_static_text()
    return c(pos, { i(nil, snip_text), snip })
  end,
})

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

local function on_the_fly_insert()
  local register = vim.fn.getcharstr()
  if #register == 1 and register:match('[%w"*+-]') then
    on_the_fly(register)
  end
end

local function on_the_fly_visual()
  return "c<C-E>" .. vim.v.register
end

-- Mappings
map("i", "<C-H>", luasnip.expand)
map({ "i", "s", "n" }, "<C-J>", luasnip_jump(1))
map({ "i", "s", "n" }, "<C-K>", luasnip_jump(-1))
map({ "i", "s", "n" }, "<C-L>", luasnip_change_choice(1))
map("i", "<C-E>", on_the_fly_insert)
map("x", "<C-E>", on_the_fly_visual, { remap = true, expr = true })
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
