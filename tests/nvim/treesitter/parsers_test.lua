local Child = require("test.Child")
local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set
local wrap_values = helpers.wrap_values

local errors = expect.error
local not_errors = expect.no_error

local child = Child.new()

local T = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["installed"] = new_set({
  parametrize = wrap_values({
    "bash",
    "go",
    "hcl",
    "javascript",
    "jinja",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "nix",
    "python",
    "rust",
    "terraform",
    "toml",
    "typescript",
    "vim",
    "xml",
    "yaml",
  }),
}, {
  test = function(lang)
    not_errors(function()
      child.lua("vim.treesitter.language.add(...)", { lang })
    end)
  end,
})

T["absent"] = new_set({
  parametrize = wrap_values({}),
}, {
  test = function(lang)
    errors(function()
      child.lua("vim.treesitter.language.add(...)", { lang })
    end, "no parser for")
  end,
})

return T
