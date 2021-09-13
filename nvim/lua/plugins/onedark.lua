local onedark = {}

function onedark.config()
  require("onedark").setup({
    keywordStyle = "NONE",
  })
  -- Restore TelescopeMatching highlight to default
  vim.api.nvim_command("highlight! link TelescopeMatching Special")
end

return onedark
