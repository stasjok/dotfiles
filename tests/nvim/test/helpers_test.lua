local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local T = new_set()

T["dedent"] = new_set({
  parametrize = {
    -- Empty input
    { { "" }, "" },
    -- No indent
    { { "a\nb" }, "a\nb" },
    -- Common indent
    { { "  a\n  b" }, "a\nb" },
    -- Not all lines are indented
    { { "  a\nb" }, "  a\nb" },
    { { "a\n  b" }, "a\n  b" },
    -- Different indent
    { { "    a\n      b\n        c" }, "a\n  b\n    c" },
    -- Empty lines
    { { "  a\n\n  b\n  c" }, "a\n\nb\nc" },
    -- Tabs
    { { "\ta\n\tb" }, "a\nb" },
    { { "\t\ta\n\tb" }, "\ta\nb" },
    -- Ignore less-indented spaces
    { { "    a\n  \n    b" }, "a\n\nb" },
    -- Doesn't ignore more-indented whitespace-only lines
    { { "  a\n    \n  b" }, "a\n  \nb" },
    -- Trims last newline
    { { "a\nb\n" }, "a\nb" },
    -- Trims only one newline
    { { "  a\n\n  b\n\n\n" }, "a\n\nb\n\n" },
    -- Last empty and less-indented line is trimmed
    { { "    a\n      b\n    c\n  " }, "a\n  b\nc" },
    { { "    a\n      b\n    c\n\n  " }, "a\n  b\nc\n" },
    -- '{opts.trim = false}'
    { { "a\nb\n", { trim = false } }, "a\nb\n" },
    { { "  a\n  \n  b\n", { trim = false } }, "a\n\nb\n" },
  },
}, {
  test = function(input, expectation)
    eq(helpers.dedent(unpack(input)), expectation)
  end,
})

T["wrap_values"] = new_set({
  parametrize = {
    -- Empty input
    { {}, {} },
    -- One element
    { { 1 }, { { 1 } } },
    -- Two elements
    { { "a", "b" }, { { "a" }, { "b" } } },
    -- Bonus: dictionary
    { { a = 1 }, { { "a", 1 } } },
  },
}, {
  test = function(input, expectation)
    eq(helpers.wrap_values(input), expectation)
  end,
})

return T
