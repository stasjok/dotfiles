local onedark = {}

function onedark.config()
  -- Apply configuration
  require("onedark.config").apply_configuration({
    keyword_style = "NONE",
    function_style = "NONE",
  })
  -- Load colors
  local theme = require("onedark.theme").setup(require("onedark.config").config)

  -- Modify theme
  theme.plugins.TelescopeMatching = { link = "Special" }

  -- Apply colorscheme
  require("onedark.util").load(theme)
end

return onedark
