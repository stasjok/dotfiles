local onedark = {}

function onedark.config()
  require("onedark").setup({
    keywordStyle = "NONE",
  })
  -- Restore TelescopeMatching highlight to default
  vim.cmd("highlight! link TelescopeMatching Special")
end

return onedark
