local editorconfig = {}

function editorconfig.config()
  vim.g.EditorConfig_exclude_patterns = { "scp://.*", "fugitive://.*" }
  vim.g.EditorConfig_preserve_formatoptions = 1
end

return editorconfig
