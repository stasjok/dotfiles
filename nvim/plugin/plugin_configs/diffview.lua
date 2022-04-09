require("diffview").setup({
  enhanced_diff_hl = true,
  key_bindings = {
    view = {
      q = '<Cmd>lua require"diffview".close()<CR>',
    },
    file_panel = {
      q = '<Cmd>lua require"diffview".close()<CR>',
    },
  },
})
