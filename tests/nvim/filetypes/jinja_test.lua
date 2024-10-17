local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local bo = child.bo
local cmd = child.cmd
local inspect_pos = child.inspect_pos
local set_lines = child.set_lines

local T = new_set({ hooks = {
  pre_case = child.setup,
  post_once = child.stop,
} })

local JINJA_FILETYPE = "jinja"

T["ftdetect"] = new_set({ parametrize = {
  { "test.jinja" },
} }, {
  test = function(filename)
    cmd.edit(filename)

    eq(bo.filetype, JINJA_FILETYPE)
  end,
})

T["ftplugin"] =
  new_set({ hooks = {
    pre_case = function()
      bo.filetype = JINJA_FILETYPE
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
  eq(bo.commentstring, "{#- %s #}")
end

T["syntax"] = new_set()

T["syntax"]["compound filetypes"] = function()
  bo.filetype = "conf.jinja"
  set_lines({
    "# Comment",
    "{{ variable }}",
  })

  eq(inspect_pos(0, 0, 4).syntax[1].hl_group, "confComment")
  eq(vim.iter(inspect_pos(0, 1, 6).syntax):rpeek().hl_group, "jinjaVariable")
end

return T
