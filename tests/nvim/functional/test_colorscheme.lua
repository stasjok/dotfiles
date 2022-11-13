local helpers = dofile("tests/nvim/minitest_helpers.lua")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq = MiniTest.expect.equality

local child = new_child()

local T = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["colorscheme"] = new_set()

T["colorscheme"]["is selected"] = function()
  eq(child.cmd_capture("colorscheme"), "kanagawa")
end

T["colorscheme"]["kanagawa"] = function()
  local colors = child.lua_get("require(...).setup()", { "kanagawa.colors" })
  -- Make sure that TermCursor color is 'sumiInk4'
  eq(
    child.api.nvim_get_hl_by_name("TermCursor", true),
    { background = tonumber(string.sub(colors.fg_border, 2), 16) }
  )
end

return T
