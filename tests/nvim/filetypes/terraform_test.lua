local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local bo = child.bo

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
  parametrize = { { "hcl" }, { "terraform" }, { "terraform-vars" } },
}, {
  test = function(filetype)
    bo.filetype = filetype

    -- Validate indentation settings
    eq(bo.expandtab, true)
    eq(bo.shiftwidth, 2)
    ok(
      bo.softtabstop < 0 or bo.softtabstop == 2,
      string.format("Expected 'softtabstop' to be -1 or 2, got %s.", bo.softtabstop)
    )

    -- Validate commentstring
    eq(bo.commentstring, "# %s")
  end,
})

return T
