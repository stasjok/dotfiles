local expect = require("test.expect")
local eq = expect.equality

local T = MiniTest.new_set()

-- A pattern to test error message
local function error_pattern(s)
  return vim.pesc(string.format("Pattern: %s\n", s))
end

T["expect.match()"] = function()
  -- Works
  eq(expect.match("test", "test"), true)
  expect.error(expect.match, error_pattern("no_match"), "test", "no_match")
  -- Works with plain pattern
  expect.error(expect.match, error_pattern("test-test"), "test-test", "test-test")
  eq(expect.match("test-test", "test-test", 1, true), true)
  -- Pattern text
  expect.error(expect.match, error_pattern("test, 2"), "test", "test", 2)
  expect.error(expect.match, error_pattern("test, 2, true"), "test", "test", 2, true)
  expect.error(expect.match, error_pattern("test, 2, false"), "test", "test", 2, false)
  expect.error(expect.match, error_pattern("no_match, nil, true"), "test", "no_match", nil, true)
  expect.error(expect.match, error_pattern("no_match"), "test", "no_match", nil, nil)
end

T["expect.no_match()"] = function()
  eq(expect.no_match("test", "no_match"), true)
  expect.error(expect.no_match, error_pattern("test"), "test", "test")
  eq(expect.no_match("test-test", "test%-test", nil, true), true)
end

return T
