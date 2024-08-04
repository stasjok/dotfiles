local expect = require("test.expect")
local new_set = MiniTest.new_set

local eq = expect.equality
local errors = expect.error
local matches = expect.matching
local not_matches = expect.no_matching

local T = new_set()

T["expect.truthy()"] = function()
  -- Truthy
  eq(expect.truthy(true), true)
  eq(expect.truthy(0), true)
  eq(expect.truthy(""), true)
  eq(expect.truthy({}), true)
  eq(expect.truthy(function() end), true)
  -- Falsy
  errors(expect.truthy, "Observed value: false", false)
  errors(expect.truthy, "Observed value: nil", nil)
  -- Message
  errors(expect.truthy, "Failed expectation for truthy value%.", false)
  errors(expect.truthy, "Error message: Want truthy%.", false, "Want truthy.")
  -- No message if not provided
  local ok, err = pcall(expect.truthy, nil)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  matches(err, "Observed value: nil")
  not_matches(err, "Error message:")
end

T["expect.falsy()"] = function()
  -- Falsy
  eq(expect.falsy(false), true)
  eq(expect.falsy(nil), true)
  -- Falsy
  errors(expect.falsy, "Observed value: true", true)
  errors(expect.falsy, "Observed value: 1", 1)
  errors(expect.falsy, [=[Observed value: ['"]a['"]]=], "a")
  errors(expect.falsy, "Observed value: { ?1 ?}", { 1 })
  -- Message
  errors(expect.falsy, "Failed expectation for falsy value%.", true)
  errors(expect.falsy, "Error message: Want falsy%.", true, "Want falsy.")
  -- No message if not provided
  local ok, err = pcall(expect.falsy, true)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  matches(err, "Observed value: true")
  not_matches(err, "Error message:")
end

T["expect.is_true()"] = function()
  -- True
  eq(expect.is_true(true), true)
  -- Not true
  errors(expect.is_true, "Observed value: false", false)
  errors(expect.is_true, "Observed value: nil", nil)
  errors(expect.is_true, "Observed value: 1", 1)
  errors(expect.is_true, [=[Observed value: ['"]a['"]]=], "a")
  errors(expect.is_true, "Observed value: { ?1 ?}", { 1 })
  -- Message
  errors(expect.is_true, "Failed expectation for true value%.", false)
  errors(expect.is_true, "Error message: Want true%.", false, "Want true.")
  -- No message if not provided
  local ok, err = pcall(expect.is_true, false)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  matches(err, "Observed value: false")
  not_matches(err, "Error message:")
end

T["expect.is_false()"] = function()
  -- False
  eq(expect.is_false(false), true)
  -- Not false
  errors(expect.is_false, "Observed value: true", true)
  errors(expect.is_false, "Observed value: nil", nil)
  errors(expect.is_false, "Observed value: 0", 0)
  errors(expect.is_false, [=[Observed value: ['"]a['"]]=], "a")
  errors(expect.is_false, "Observed value: { ?}", {})
  -- Message
  errors(expect.is_false, "Failed expectation for false value%.", true)
  errors(expect.is_false, "Error message: Want false%.", true, "Want false.")
  -- No message if not provided
  local ok, err = pcall(expect.is_false, true)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  matches(err, "Observed value: true")
  not_matches(err, "Error message:")
end

return T
