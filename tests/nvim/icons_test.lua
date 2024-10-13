local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local not_errors = expect.no_error

local child = Child.new()
local lua_get = child.lua_get

local T = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["web-devicons"] = function()
  not_errors(child.lua, 'require("nvim-web-devicons")')
  eq(lua_get('require("nvim-web-devicons").get_icon("test.lua")'), "")
end

return T
