local minitest = require("mini.test")

-- Provide all MiniTest expectations
M = vim.deepcopy(minitest.expect, true)

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
function M.match(string, pattern, init, plain)
  return match_expectation(string, pattern, init, plain)
end

--- Expect string to not match pattern
---
---@param string string String to be tested for pattern matching
---@param pattern string Pattern which string should not match
---@param init? integer Where to start the match, default is 1
---@param plain? boolean Whether to match pattern literally
---@return true
function M.no_match(string, pattern, init, plain)
  return no_match_expectation(string, pattern, init, plain)
end

return M
