local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local T = new_set()

T["dedent"] = new_set({
  parametrize = {
    -- Empty input
    { "", "" },
    -- No indent
    { "a\nb", "a\nb" },
    -- Common indent
    { "  a\n  b", "a\nb" },
    -- Not all lines are indented
    { "  a\nb", "  a\nb" },
    { "a\n  b", "a\n  b" },
    -- Different indent
    { "    a\n      b\n        c", "a\n  b\n    c" },
    -- Empty lines
    { "  a\n\n  b\n", "a\n\nb\n" },
    -- Tabs
    { "\ta\n\tb", "a\nb" },
    { "\t\ta\n\tb", "\ta\nb" },
  },
}, {
  test = function(input, expectation)
    eq(helpers.dedent(input), expectation)
  end,
})

return T
