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
    "jinja2", -- For LuaSnip ft_func
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
    not_errors(child.lua, "vim.treesitter.language.add(...)", { lang })
  end,
})

T["absent"] = new_set({
  parametrize = wrap_values({}),
}, {
  test = function(lang)
    errors(child.lua, "no parser for", "vim.treesitter.language.add(...)", { lang })
  end,
})

T["jinja2 parser is suitable for luasnip ft_func"] = function()
  not_errors(child.lua, 'vim.treesitter.query.parse("jinja2", "(jinja_stuff) (text)")')
end

return T
