local luasnip = require("luasnip")
local on_the_fly = require("luasnip.extras.otf").on_the_fly
local extend_load_ft = require("luasnip.extras.filetype_functions").extend_load_ft
local map = vim.keymap.set
local s = luasnip.snippet
local i = luasnip.insert_node
local c = luasnip.choice_node
local win_get_cursor = vim.api.nvim_win_get_cursor
local buf_get_text = vim.api.nvim_buf_get_text

-- Filetypes
luasnip.filetype_set("sls", { "sls", "jinja" })
luasnip.filetype_set("ansible", { "ansible", "jinja", "jinja2" })
luasnip.filetype_set("jinja2", { "jinja2", "jinja" })

---Returns `ft_func` for filetypes using jinja
---@param ft string Fallback filetype
---@return function
local function jinja_ft_func(ft)
  return function()
    ---@type {[1]: integer, [2]: integer}
    local pos = win_get_cursor(0)
    ---@type string[]
    local context = buf_get_text(
      0,
      pos[1] >= 2 and pos[1] - 2 or pos[1] - 1,
      0,
      pos[1] - 1,
      pos[2],
      {}
    )
    if #context == 1 then
      table.insert(context, 1, "")
    end
    if context[2]:find("|%s*[%w_]*$", -20) or context[1]:sub(-1) == "|" then
      return { "jinja_filters" }
    elseif context[2]:find("is%s+[%w_]*$", -20) then
      return { "jinja_tests" }
    else
      return { ft, "jinja_statements" }
    end
  end
end

local ft_func = {
  jinja = jinja_ft_func("jinja"),
  jinja2 = jinja_ft_func("jinja2"),
  sls = jinja_ft_func("sls"),
  ansible = jinja_ft_func("ansible"),
}

setmetatable(ft_func, {
  __call = function(t)
    local buf_filetypes = vim.split(vim.bo.filetype, ".", { plain = true })
    local filetypes = {}
    for _, ft in ipairs(buf_filetypes) do
      vim.list_extend(filetypes, t[ft] and t[ft]() or { ft })
    end
    return filetypes
  end,
})

local jinja_virtual = { "jinja_statements", "jinja_filters", "jinja_tests" }

-- Configuration
luasnip.config.setup({
  updateevents = "TextChanged,TextChangedI",
  region_check_events = "InsertEnter",
  store_selection_keys = "<C-H>",
  snip_env = nil,
  ft_func = ft_func,
  load_ft_func = extend_load_ft({
    jinja = vim.list_slice(jinja_virtual),
    jinja2 = vim.list_slice(jinja_virtual),
    sls = vim.list_slice(jinja_virtual),
    ansible = vim.list_slice(jinja_virtual),
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
