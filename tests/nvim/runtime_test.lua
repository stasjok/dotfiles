local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local matches = expect.matching

local child = Child.new()
local lua_get = child.lua_get
local env = child.env

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["runtimepath"] = function()
  local rtp = lua_get("vim.opt.runtimepath:get()")
  -- The test environment uses symlinks for home directory.
  -- Stdpath() returns resolved path. Resolve runtime path before comparing.
  matches(rtp[1], "nvim%-config$")
  matches(rtp[2], "vim%-pack%-dir$")
  matches(rtp[3], "vim%-pack%-dir/pack/%*/start/%*$")
  eq(rtp[4], env.VIMRUNTIME)
  matches(rtp[5], "vim%-pack%-dir/pack/%*/start/%*/after$")
  matches(rtp[6], "nvim%-config/after$")
  eq(#rtp, 6)
end

T["packpath"] = function()
  local packpath = lua_get("vim.opt.packpath:get()")
  matches(packpath[1], "vim%-pack%-dir$")
  eq(packpath[2], env.VIMRUNTIME)
  eq(#packpath, 2)
end

return T
