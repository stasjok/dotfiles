local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local helpers = dofile("tests/nvim/helpers_minitest.lua")

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

return T
