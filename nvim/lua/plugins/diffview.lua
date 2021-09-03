local diffview = {}

function diffview.config()
  require("diffview").setup({
    key_bindings = {
      view = {
        q = '<Cmd>lua require"diffview".close()<CR>',
      },
      file_panel = {
        q = '<Cmd>lua require"diffview".close()<CR>',
      },
    },
  })
end

return diffview
