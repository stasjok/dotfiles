local luasnip = require("luasnip")
local map = vim.keymap.set

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
    require("luasnip.extras.otf").on_the_fly(register)
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

-- Clear LuaSnip FS watcher autocommands
vim.api.nvim_del_augroup_by_name("_luasnip_fs_watcher")
