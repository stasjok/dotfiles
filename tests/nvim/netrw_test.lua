local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local cmd = child.cmd
local fn = child.fn
local bo = child.bo

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["works"] = function()
  eq(fn.exists("g:loaded_netrwPlugin"), 1)
  -- The plugin is actually loaded
  eq(fn.exists(":Nread"), 2)
  eq(fn.exists(":Nwrite"), 2)
  eq(fn.exists(":Ntree"), 2)
  -- Help file is available
  eq(fn.getcompletion("netrw-start", "help"), { "netrw-start" })
  -- Works
  cmd("Ntree")
  eq(bo.filetype, "netrw")
  eq(bo.syntax, "netrw")
end

return T
