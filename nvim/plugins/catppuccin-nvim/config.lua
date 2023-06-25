require("catppuccin").setup({
  flavour = "macchiato",
  background = {
    light = "latte",
    dark = "macchiato",
  },
  integrations = {
    -- Disable default
    nvimtree = false,
    dashboard = false,
    ts_rainbow = false,
    indent_blankline = { enabled = false },
    -- Enable optional
    mini = true,
  },
  custom_highlights = function(_)
    return {
      TermCursor = { bg = "#179299" },
      -- Don't hide tree-sitter comment highlights
      ["@lsp.type.comment.lua"] = {},
    }
  end,
})
require("catppuccin").load()
