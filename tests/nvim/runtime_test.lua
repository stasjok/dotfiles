local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local matches = expect.matching

local child = Child.new()
local fn = child.fn
local lua_get = child.lua_get
local env = child.env

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["runtimepath"] = function()
  local rtp = lua_get("vim.opt.runtimepath:get()")
  -- Test environment uses symlinks for home directory.
  -- Stdpath() returns resolved path. Resolve runtime path before comparing.
  eq(vim.uv.fs_realpath(rtp[1]), fn.stdpath("config"))
  matches(rtp[2], "vim%-pack%-dir$")
  matches(rtp[3], "vim%-pack%-dir/pack/%*/start/%*$")
  eq(rtp[4], env.VIMRUNTIME)
  -- TODO: Get rid of opt plugins in rtp
  eq(rtp[5], env.VIMRUNTIME .. "/pack/dist/opt/matchit")
  matches(rtp[6], "vim%-pack%-dir/pack/%*/start/%*/after$")
  eq(vim.uv.fs_realpath(rtp[7]), fn.stdpath("config") .. "/after")
  eq(#rtp, 7)
end

T["packpath"] = function()
  local packpath = lua_get("vim.opt.packpath:get()")
  matches(packpath[1], "vim%-pack%-dir$")
  eq(packpath[2], env.VIMRUNTIME)
  eq(#packpath, 2)
end

return T
