require("catppuccin").setup({
  -- Compile colorscheme to $out/colors/
  compile_path = vim.fs.joinpath(vim.env.out, "colors"),

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
