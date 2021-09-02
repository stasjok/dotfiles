local bashls = {}

bashls.root_dir = function(filename)
  return require("lspconfig.util").root_pattern(".git")(filename)
    or require("lspconfig.util").path.dirname(filename)
end

return bashls
