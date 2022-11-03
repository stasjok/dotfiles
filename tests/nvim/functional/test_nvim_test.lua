local new_set = MiniTest.new_set
local helpers = dofile("tests/nvim/helpers_minitest.lua")
local expect, eq = helpers.expect, MiniTest.expect.equality

local child = helpers.new_child()

local T = new_set({
  hooks = {
    pre_case = function()
      child.setup()
    end,
    post_once = child.stop,
  },
})

T["nvim"] = function()
  eq(child.is_running(), true)
  eq(child.is_blocked(), false)
end

T["runtimepath"] = function()
  local rtp = child.lua_get("vim.opt.runtimepath:get()")
  eq(rtp[1], vim.fn.fnamemodify("nvim", ":p:h"))
  expect.match(rtp[2], "vim%-pack%-dir$")
  expect.match(rtp[3], "vim-pack-dir/pack/*/start/*", 1, true)
  eq(rtp[4], vim.env.VIMRUNTIME)
  expect.match(rtp[#rtp - 1], "vim-pack-dir/pack/*/start/*/after", 1, true)
  eq(rtp[#rtp], vim.fn.fnamemodify("nvim/after", ":p:h"))
end

T["packpath"] = function()
  local packpath = child.lua_get("vim.opt.packpath:get()")
  expect.match(packpath[1], "vim%-pack%-dir$")
  eq(packpath[2], vim.env.VIMRUNTIME)
  eq(#packpath, 2)
end

return T
