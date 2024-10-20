local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local lua_func = child.lua_func

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["config"] = new_set({
  parametrize = {
    { { "default_amount" }, 2 },
    { { "at_edge" }, "wrap" },
    { { "log_level" }, "error" },
  },
}, {
  test = function(path, expectation)
    local option = lua_func(function()
      return vim.tbl_get(require("smart-splits.config"), unpack(path))
    end)
    eq(option, expectation)
  end,
})

return T
