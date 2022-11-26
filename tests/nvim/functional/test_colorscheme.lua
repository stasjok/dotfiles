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
  eq(child.lua_get("require('catppuccin').options.background"), {
    light = "latte",
    dark = "macchiato",
  })
  eq(child.lua_get("require('catppuccin').options.transparent_background"), false)
  eq(child.lua_get("require('catppuccin').options.term_colors"), false)
  eq(child.lua_get("require('catppuccin').options.dim_inactive.enabled"), false)

  -- Styles
  eq(child.lua_get("require('catppuccin').options.styles"), {
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
    eq({
      integration = child.lua_get(
        "require('catppuccin').options.integrations[...]",
        { integration }
      ),
    }, { integration = opts })
  end

  -- Color overrides
  eq(child.lua_get("require('catppuccin').options.color_overrides"), {})

  -- Highlight groups
  local groups = child.api.nvim__get_hl_defs(0)
  ---@param color string Hex color like `#aaaaaa`
  ---@return integer
  local function to_int(color)
    return tonumber(string.sub(color, 2), 16)
  end
  eq(groups.TermCursor, { background = to_int("#179299") })
  eq(groups["@text.diff.add"], { link = "diffAdded" })
  eq(groups["@text.diff.delete"], { link = "diffRemoved" })
end

return T
