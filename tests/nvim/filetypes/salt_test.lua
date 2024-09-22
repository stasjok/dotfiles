local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local bo = child.bo
local cmd = child.cmd

local T = new_set({ hooks = {
  pre_case = child.setup,
  post_once = child.stop,
} })

local SALT_FILETYPE = "salt"

T["ftdetect"] = new_set({ parametrize = {
  { "test.sls" },
} }, {
  test = function(filename)
    cmd.edit(filename)

    eq(bo.filetype, SALT_FILETYPE)
  end,
})

T["ftplugin"] =
  new_set({ hooks = {
    pre_case = function()
      bo.filetype = SALT_FILETYPE
    end,
  } })

T["ftplugin"]["options"] = function()
  -- Validate indentation settings
  eq(bo.expandtab, true)
  eq(bo.shiftwidth, 2)
  ok(
    bo.softtabstop < 0 or bo.softtabstop == 2,
    string.format("Expected 'softtabstop' to be -1 or 2, got %s.", bo.softtabstop)
  )

  -- Validate commentstring
  eq(bo.commentstring, "# %s")
end

return T
