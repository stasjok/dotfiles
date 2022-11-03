local helpers = {}

-- Add extra expectations
helpers.expect = vim.deepcopy(MiniTest.expect)

local function match_fail_context(str, pattern, init, plain)
  if plain ~= nil then
    init = init or "nil"
    pattern = string.format("%s, %s, %s", pattern, init, plain)
  elseif init then
    pattern = string.format("%s, %s", pattern, init)
  end
  return string.format("Pattern: %s\nObserved string: %s", pattern, str)
end

helpers.expect.match = MiniTest.new_expectation(
  "string matching",
  function(str, pattern, init, plain)
    return str:find(pattern, init, plain) ~= nil
  end,
  match_fail_context
)

helpers.expect.no_match = MiniTest.new_expectation(
  "no string matching",
  function(str, pattern, init, plain)
    return str:find(pattern, init, plain) == nil
  end,
  match_fail_context
)

-- Modified new_child_neovim()
helpers.new_child = function(minimal)
  minimal = minimal == nil and true or minimal

  local child = MiniTest.new_child_neovim()
  local init = minimal and "tests/nvim/minimal_init.lua" or "nvim/init.lua"

  child.setup = function()
    child.restart(
      { "-u", init, "--cmd", "set rtp^=nvim" },
      { nvim_executable = vim.env.NVIMPATH or "nvim" }
    )
    child.bo.readonly = false
  end

  return child
end

return helpers
