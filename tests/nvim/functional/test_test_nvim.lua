local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local assert = require("luassert")

local T = new_set()

T["empty"] = function() end

return T
