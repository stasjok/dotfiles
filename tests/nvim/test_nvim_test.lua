local expect = require("test.expect")
local eq = expect.equality
local helpers = require("test.helpers")
local new_set = MiniTest.new_set

local child = helpers.new_child()

local T = new_set()

T["child"] = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["child"]["nvim"] = function()
  eq(child.is_running(), true)
  eq(child.is_blocked(), false)
end

T["child"]["runtimepath"] = function()
  local rtp = child.lua_get("vim.opt.runtimepath:get()")
  eq(rtp[1], vim.uv.fs_realpath(vim.fs.normalize("~/.config/nvim")))
  expect.match(rtp[2], "vim%-pack%-dir$")
  expect.match(rtp[3], "vim-pack-dir/pack/*/start/*", 1, true)
  eq(rtp[4], child.env.VIMRUNTIME)
  expect.match(rtp[#rtp - 1], "vim-pack-dir/pack/*/start/*/after", 1, true)
  eq(rtp[#rtp], vim.uv.fs_realpath(vim.fs.normalize("~/.config/nvim/after")))
end

T["child"]["packpath"] = function()
  local packpath = child.lua_get("vim.opt.packpath:get()")
  expect.match(packpath[1], "vim%-pack%-dir$")
  eq(packpath[2], child.env.VIMRUNTIME)
  eq(#packpath, 2)
end

return T
