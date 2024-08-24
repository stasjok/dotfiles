local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local ok = expect.assertion

local child = Child.new()

T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

local function test(scope)
  return function(option, expected)
    ok(
      vim.deep_equal(child[scope][option], expected),
      string.format(
        "Expected vim.%s.%s == %s, got %s.",
        scope,
        option,
        expected,
        child[scope][option]
      )
    )
  end
end

T["o"] = new_set({
  parametrize = {
    { "termguicolors", true },
    { "background", "dark" },
    { "foldlevelstart", 99 },
  },
}, { test = test("o") })

T["go"] = new_set({ parametrize = {} }, { test = test("go") })

T["wo"] = new_set({ parametrize = {} }, { test = test("wo") })

T["bo"] = new_set({ parametrize = {} }, { test = test("bo") })

return T
