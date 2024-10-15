local Child = require("test.Child")
local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set
local wrap_values = helpers.wrap_values

local ok = expect.assertion

local child = Child.new()
local bo = child.bo
local lua_func = child.lua_func

local T = new_set({
  hooks = {
    pre_case = function()
      child.setup()
      child.disable_lsp_autostart()
    end,
    post_once = child.stop,
  },
})

T["active"] = new_set({
  parametrize = wrap_values({
    "bash",
    "go",
    "lua",
    "nix",
    "python",
    -- Custom filetypes
    "terraform-vars",
  }),
}, {
  test = function(filetype)
    bo.filetype = filetype
    ok(
      lua_func(function()
        return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
      end),
      "Tree-sitter highlighter is expected to be active."
    )
  end,
})

T["inactive"] = new_set({
  parametrize = wrap_values({
    -- Jinja blocks isn't highlighted with treesitter
    "yaml.ansible",
  }),
}, {
  test = function(filetype)
    bo.filetype = filetype
    ok(lua_func(function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] == nil
    end))
  end,
})

return T
