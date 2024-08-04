local minitest = require("mini.test")

-- Provide all MiniTest expectations
local expect = vim.deepcopy(minitest.expect, true)

-- For backward compatibility
expect.match = expect.matching
expect.no_match = expect.no_matching
expect.assert = expect.assertion

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

return expect
