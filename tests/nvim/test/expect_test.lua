local expect = require("test.expect")
local eq = expect.equality

local T = MiniTest.new_set()

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

return T
