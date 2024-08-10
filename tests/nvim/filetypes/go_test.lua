local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local bo = child.bo
local wo = child.wo

local T = new_set({ hooks = {
  pre_case = child.setup,
  post_once = child.stop,
} })

T["ftplugin"] = new_set({
  hooks = {
    pre_case = function()
      child.disable_lsp_autostart()
    end,
  },
  parametrize = { { "go" }, { "gomod" } },
}, {
  test = function(filetype)
    bo.filetype = filetype

    -- Validate indentation settings
    eq(bo.expandtab, false)
    eq(bo.tabstop, 4)
    eq(bo.shiftwidth, 0)
    ok(
      bo.softtabstop <= 0,
      string.format("Expected 'softtabstop' to be 0 or -1, got %s.", bo.softtabstop)
    )

    -- No visible tabs
    eq(wo.list, false)
  end,
})

return T
