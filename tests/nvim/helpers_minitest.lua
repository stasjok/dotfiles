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
helpers.new_child = function(opts)
  opts = vim.tbl_extend("keep", opts or {}, { minimal = false }) --[[@as table]]

  local child = MiniTest.new_child_neovim()

  local args
  if opts.minimal then
    args = { "-u", "tests/nvim/minimal_init.lua", "--noplugin" }
  else
    args = { "-u", "nvim/init.lua" }
  end
  -- Because MiniTest uses `--clean` arg, we need to add home directory (current) manually
  vim.list_extend(args, { "--cmd", "set runtimepath^=nvim" })

  child.setup = function()
    child.restart(args, { nvim_executable = vim.env.NVIMPATH or "nvim" })
    child.bo.readonly = false
  end

  return child
end

return helpers
