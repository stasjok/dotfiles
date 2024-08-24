local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local cmd_capture = child.cmd_capture

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["colorscheme"] = function()
  eq(cmd_capture("colorscheme"), "catppuccin-macchiato")
end

return T
