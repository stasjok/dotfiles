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
  eq(child.cmd_capture("colorscheme"), "catppuccin")
end

T["colorscheme"]["catppuccin options"] = function()
  -- Flavor
  eq(child.lua_get("require('catppuccin').flavour"), "macchiato")

  -- Options
  local options = child.lua_get("require('catppuccin').options")
  eq(options.background, {
    light = "latte",
    dark = "macchiato",
  })
  eq(options.transparent_background, false)
  eq(options.term_colors, false)
  eq(options.dim_inactive.enabled, false)

  -- Styles
  eq(options.styles, {
    comments = { "italic" },
    conditionals = {},
    loops = {},
    functions = {},
    keywords = { "italic" },
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  })

  -- Integrations
  for integration, opts in pairs({
    -- should be disabled
    nvimtree = false,
    dashboard = false,
    indent_blankline = false,
    -- should be enabled
    treesitter = true,
    cmp = true,
    gitsigns = true,
    telescope = true,
    markdown = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
    },
    mini = true,
  }) do
    eq({ integration = options.integrations[integration] }, { integration = opts })
  end

  -- Overrides
  eq(options.color_overrides, {})
  eq(options.highlight_overrides, {})
end

return T
