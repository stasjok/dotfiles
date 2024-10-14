local Child = require("test.Child")
local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local dedent = helpers.dedent

local eq = expect.equality

local child = Child.new()
local cmd = child.cmd
local get_lines = child.get_lines

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

local skeletons = {
  ["dotfiles/tests/nvim"] = {
    files = { "tests/nvim/abcdef_test.lua", "tests/nvim/lua/abcdef_test.lua" },
    content = dedent([[
      local Child = require("test.Child")
      local expect = MiniTest.expect
      local new_set = MiniTest.new_set

      local eq = expect.equality
      local ok = expect.assertion

      local child = Child.new()

      local T = new_set({
        hooks = {
          pre_case = child.setup,
          post_once = child.stop,
        },
      })



      return T
    ]]),
    cursor_line = 17,
  },
}

for name, opts in pairs(skeletons) do
  local function test(file)
    cmd.edit(file or opts.files)
    eq(get_lines({ join = true }), opts.content)
    eq(child.get_cursor(), opts.cursor_line)
  end

  if type(opts.files) == "table" then
    T[name] = new_set({
      parametrize = vim.tbl_map(function(f)
        return { f }
      end, opts.files),
    }, { test = test })
  else
    T[name] = test
  end
end

return T
