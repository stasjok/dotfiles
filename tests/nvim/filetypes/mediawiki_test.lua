local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local feed_keys = child.feed_keys
local get_lines = child.get_lines
local cmd = child.cmd
local bo = child.bo
local wo = child.wo

local T = new_set({ hooks = {
  pre_case = child.setup,
  post_once = child.stop,
} })

T["ftdetect"] = new_set({ parametrize = { { "test.mw" }, { "test.mediawiki" } } }, {
  test = function(filename)
    cmd.edit(filename)

    eq(bo.filetype, "mediawiki")
  end,
})

T["ftplugin"] = new_set({
  hooks = {
    pre_case = function()
      bo.filetype = "mediawiki"
    end,
  },
})

T["ftplugin"]["options"] = function()
  -- Infinite line length with line wrapping
  eq(wo.wrap, true)
  eq(wo.linebreak, true)
  eq(bo.textwidth, 0)
  eq(bo.wrapmargin, 0)
  for _, letter in ipairs({ "t", "c", "a" }) do
    ok(
      bo.formatoptions:find(letter) == nil,
      string.format("Expected no '%s' in formatoptions.", letter)
    )
  end
end

T["ftplugin"]["lists"] = new_set({ parametrize = {
  { "*" },
  { "#" },
  { ":" },
} }, {
  test = function(item)
    feed_keys("i", item, " ", "item 1", "<CR>", "item 2")
    eq(get_lines({ join = true }), string.format("%s item 1\n%s item 2", item, item))
  end,
})

return T
