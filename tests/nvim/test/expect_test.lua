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

T["expect.truthy()"] = function()
  -- Truthy
  eq(expect.truthy(true), true)
  eq(expect.truthy(0), true)
  eq(expect.truthy(""), true)
  eq(expect.truthy({}), true)
  eq(expect.truthy(function() end), true)
  -- Falsy
  expect.error(expect.truthy, "Observed value: false", false)
  expect.error(expect.truthy, "Observed value: nil", nil)
  -- Message
  expect.error(expect.truthy, "Failed expectation for truthy value%.", false)
  expect.error(expect.truthy, "Error message: Want truthy%.", false, "Want truthy.")
  -- No message if not provided
  local ok, err = pcall(expect.truthy, nil)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  expect.match(err, "Observed value: nil")
  expect.no_match(err, "Error message:")
end

T["expect.falsy()"] = function()
  -- Falsy
  eq(expect.falsy(false), true)
  eq(expect.falsy(nil), true)
  -- Falsy
  expect.error(expect.falsy, "Observed value: true", true)
  expect.error(expect.falsy, "Observed value: 1", 1)
  expect.error(expect.falsy, [=[Observed value: ['"]a['"]]=], "a")
  expect.error(expect.falsy, "Observed value: { ?1 ?}", { 1 })
  -- Message
  expect.error(expect.falsy, "Failed expectation for falsy value%.", true)
  expect.error(expect.falsy, "Error message: Want falsy%.", true, "Want falsy.")
  -- No message if not provided
  local ok, err = pcall(expect.falsy, true)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  expect.match(err, "Observed value: true")
  expect.no_match(err, "Error message:")
end

T["expect.is_true()"] = function()
  -- True
  eq(expect.is_true(true), true)
  -- Not true
  expect.error(expect.is_true, "Observed value: false", false)
  expect.error(expect.is_true, "Observed value: nil", nil)
  expect.error(expect.is_true, "Observed value: 1", 1)
  expect.error(expect.is_true, [=[Observed value: ['"]a['"]]=], "a")
  expect.error(expect.is_true, "Observed value: { ?1 ?}", { 1 })
  -- Message
  expect.error(expect.is_true, "Failed expectation for true value%.", false)
  expect.error(expect.is_true, "Error message: Want true%.", false, "Want true.")
  -- No message if not provided
  local ok, err = pcall(expect.is_true, false)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  expect.match(err, "Observed value: false")
  expect.no_match(err, "Error message:")
end

T["expect.is_false()"] = function()
  -- False
  eq(expect.is_false(false), true)
  -- Not false
  expect.error(expect.is_false, "Observed value: true", true)
  expect.error(expect.is_false, "Observed value: nil", nil)
  expect.error(expect.is_false, "Observed value: 0", 0)
  expect.error(expect.is_false, [=[Observed value: ['"]a['"]]=], "a")
  expect.error(expect.is_false, "Observed value: { ?}", {})
  -- Message
  expect.error(expect.is_false, "Failed expectation for false value%.", true)
  expect.error(expect.is_false, "Error message: Want false%.", true, "Want false.")
  -- No message if not provided
  local ok, err = pcall(expect.is_false, true)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  expect.match(err, "Observed value: true")
  expect.no_match(err, "Error message:")
end

T["expect.assert()"] = function()
  -- Truthy
  eq(expect.assert(true), true)
  eq(expect.assert(0), true)
  eq(expect.assert(""), true)
  eq(expect.assert({}), true)
  eq(expect.assert(function() end), true)
  -- Falsy
  expect.error(expect.assert, "Observed value: false", false)
  expect.error(expect.assert, "Observed value: nil", nil)
  -- Assertion message
  expect.error(expect.assert, "Failed expectation for an assertion%.", 2 < 1)
  expect.error(expect.assert, "Assertion: 2 < 1", 2 < 1, "2 < 1")
  -- No message if not provided
  local ok, err = pcall(expect.assert, nil)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  expect.match(err, "Observed value: nil")
  expect.no_match(err, "Assertion:")
end

return T
