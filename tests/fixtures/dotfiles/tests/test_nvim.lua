local helpers = require("test.helpers")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq = MiniTest.expect.equality

local child = new_child()

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["test"] = function()
  -- Ensure there are diagnostics to wait for
  eq(nil, _NOT_EXISTENT)
  eq(1, 1)
end

return T
