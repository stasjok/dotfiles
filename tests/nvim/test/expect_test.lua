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
  errors(function()
    expect.truthy(false)
  end, "Observed value: false")
  errors(function()
    expect.truthy(nil)
  end, "Observed value: nil")
  -- Message
  errors(function()
    expect.truthy(false)
  end, "Failed expectation for truthy value")
  errors(function()
    expect.truthy(false, "Want truthy.")
  end, "Error message: Want truthy")
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
  errors(function()
    expect.falsy(true)
  end, "Observed value: true")
  errors(function()
    expect.falsy(1)
  end, "Observed value: 1")
  errors(function()
    expect.falsy("a")
  end, [=[Observed value: ['"]a['"]]=])
  errors(function()
    expect.falsy({ 1 })
  end, "Observed value: { ?1 ?}")
  -- Message
  errors(function()
    expect.falsy(true)
  end, "Failed expectation for falsy value")
  errors(function()
    expect.falsy(true, "Want falsy.")
  end, "Error message: Want falsy")
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
  errors(function()
    expect.is_true(false)
  end, "Observed value: false")
  errors(function()
    expect.is_true(nil)
  end, "Observed value: nil")
  errors(function()
    expect.is_true(1)
  end, "Observed value: 1")
  errors(function()
    expect.is_true("a")
  end, [=[Observed value: ['"]a['"]]=])
  errors(function()
    expect.is_true({ 1 })
  end, "Observed value: { ?1 ?}")
  -- Message
  errors(function()
    expect.is_true(false)
  end, "Failed expectation for true value")
  errors(function()
    expect.is_true(false, "Want true.")
  end, "Error message: Want true")
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
  errors(function()
    expect.is_false(true)
  end, "Observed value: true")
  errors(function()
    expect.is_false(nil)
  end, "Observed value: nil")
  errors(function()
    expect.is_false(0)
  end, "Observed value: 0")
  errors(function()
    expect.is_false("a")
  end, [=[Observed value: ['"]a['"]]=])
  errors(function()
    expect.is_false({})
  end, "Observed value: { ?}")
  -- Message
  errors(function()
    expect.is_false(true)
  end, "Failed expectation for false value")
  errors(function()
    expect.is_false(true, "Want false.")
  end, "Error message: Want false")
  -- No message if not provided
  local ok, err = pcall(expect.is_false, true)
  eq(ok, false)
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast err string
  matches(err, "Observed value: true")
  not_matches(err, "Error message:")
end

return T
