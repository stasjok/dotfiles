local minitest = require("mini.test")

-- Provide all MiniTest expectations
local expect = vim.deepcopy(minitest.expect, true)

--
-- String matching expectations
--

local function match_fail_context(str, pattern, init, plain)
  if plain ~= nil then
    init = init or "nil"
    pattern = string.format("%s, %s, %s", pattern, init, plain)
  elseif init then
    pattern = string.format("%s, %s", pattern, init)
  end
  return string.format("Pattern: %s\nObserved string: %s", pattern, str)
end

local match_expectation = minitest.new_expectation(
  "string matching",
  function(str, pattern, init, plain)
    return str:find(pattern, init, plain) ~= nil
  end,
  match_fail_context
)

local no_match_expectation = minitest.new_expectation(
  "*no* string matching",
  function(str, pattern, init, plain)
    return str:find(pattern, init, plain) == nil
  end,
  match_fail_context
)

--- Expect string to match pattern
---
---@param string string String to be tested for pattern matching
---@param pattern string Pattern which string should match
---@param init? integer Where to start the match, default is 1
---@param plain? boolean Whether to match pattern literally
---@return true
function expect.match(string, pattern, init, plain)
  return match_expectation(string, pattern, init, plain)
end

--- Expect string to not match pattern
---
---@param string string String to be tested for pattern matching
---@param pattern string Pattern which string should not match
---@param init? integer Where to start the match, default is 1
---@param plain? boolean Whether to match pattern literally
---@return true
function expect.no_match(string, pattern, init, plain)
  return no_match_expectation(string, pattern, init, plain)
end

--
-- Boolean expectations
--

local function value_with_message_context(value, message)
  return vim
    .iter({ message and "Error message: " .. message, "Observed value: " .. vim.inspect(value) })
    :join("\n")
end

local truthy_expectation = minitest.new_expectation("truthy value", function(value)
  return value
end, value_with_message_context)

local falsy_expectation = minitest.new_expectation("falsy value", function(value)
  return not value
end, value_with_message_context)

local is_true_expectation = minitest.new_expectation("true value", function(value)
  return value == true
end, value_with_message_context)

local is_false_expectation = minitest.new_expectation("false value", function(value)
  return value == false
end, value_with_message_context)

--- Expect value to be truthy
---
---@param value any Value to be tested
---@param message? string Optional error message
---@return true
function expect.truthy(value, message)
  return truthy_expectation(value, message)
end

--- Expect value to be falsy
---
---@param value any Value to be tested
---@param message? string Optional error message
---@return true
function expect.falsy(value, message)
  return falsy_expectation(value, message)
end

--- Expect value to be true
---
---@param value any Value to be tested
---@param message? string Optional error message
---@return true
function expect.is_true(value, message)
  return is_true_expectation(value, message)
end

--- Expect value to be false
---
---@param value any Value to be tested
---@param message? string Optional error message
---@return true
function expect.is_false(value, message)
  return is_false_expectation(value, message)
end

--
-- Assertion
--

local assert_expectation = minitest.new_expectation("an assertion", function(assertion)
  return assertion
end, function(value, message)
  return vim
    .iter({ message and "Assertion: " .. message, "Observed value: " .. vim.inspect(value) })
    :join("\n")
end)

--- Expect value to be truthy. Similar to `assert()`.
---
---@param value any Value to be asserted
---@param message? string Optional assertion message
---@return true
function expect.assert(value, message)
  return assert_expectation(value, message)
end

return expect
