local helpers = dofile("tests/nvim/minitest_helpers.lua")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq = MiniTest.expect.equality

local child = new_child()

local T = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["colorscheme"] = function()
  eq(child.cmd_capture("colorscheme"), "kanagawa")
end

return T
