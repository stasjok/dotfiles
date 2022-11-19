local status, catppuccin = pcall(require, "catppuccin")

if status then
  catppuccin.setup({
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
      indent_blankline = false,
      -- Enable optional
      mini = true,
    },
  })
  catppuccin.load()
end
