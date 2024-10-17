local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local fn = child.fn
local g = child.g
local get_cursor = child.get_cursor
local set_lines = child.set_lines
local type_keys = child.type_keys

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["works"] = function()
  eq(g.loaded_matchit, 1)
  -- The plugin is actually loaded
  eq(fn.exists(":MatchDisable"), 2)
  eq(fn.mapcheck("%", "n"), "<Plug>(MatchitNormalForward)")
  -- Help file is available
  eq(fn.getcompletion("matchit.vim", "help"), { "matchit.vim" })
  -- Works
  set_lines("(test)")
  eq({ get_cursor() }, { 1, 0 })
  type_keys("%")
  eq({ get_cursor() }, { 1, 5 })
end

return T
