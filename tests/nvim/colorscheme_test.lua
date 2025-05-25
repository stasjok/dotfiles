local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local api = child.api
local cmd_capture = child.cmd_capture

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["colorscheme"] = function()
  eq(cmd_capture("colorscheme"), "catppuccin-macchiato")
end

T["highlight groups"] = new_set({
  parametrize = {
    -- LSP semantic tokens don't overlap 'comment' tree-sitter highlights
    { "@lsp.type.comment.lua", {}, true },
    { "@lsp.type.comment.nix", {}, true },
  },
}, {
  test = function(group, expectation, link)
    eq(api.nvim_get_hl(0, { name = group, link = link, create = false }), expectation)
  end,
})

return T
