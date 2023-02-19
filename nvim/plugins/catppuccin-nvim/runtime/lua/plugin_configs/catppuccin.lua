local M = {}

function M.configure()
  require("catppuccin").setup({
    compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
    flavour = "macchiato",
    background = {
      light = "latte",
      dark = "macchiato",
    },
    styles = {
      conditionals = {},
      keywords = { "italic" },
    },
    integrations = {
      -- Disable default
      nvimtree = false,
      dashboard = false,
      ts_rainbow = false,
      indent_blankline = false,
      -- Enable optional
      mini = true,
    },
    custom_highlights = function(_)
      return {
        TermCursor = { bg = "#179299" },
      }
    end,
  })
end

return M
