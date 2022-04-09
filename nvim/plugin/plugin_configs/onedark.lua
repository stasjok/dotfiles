require("onedark").setup({
  keyword_style = "NONE",
  hide_inactive_statusline = false,
  overrides = function()
    return {
      TelescopeMatching = { link = "String" },
    }
  end,
})
