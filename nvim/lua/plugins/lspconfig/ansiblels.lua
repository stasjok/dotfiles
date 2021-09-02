local ansiblels = {}

ansiblels.filetypes = { "yaml.ansible" }

ansiblels.root_dir = function(filename)
  return require("lspconfig.util").root_pattern("ansible.cfg", ".git")(filename)
    or require("lspconfig.util").path.dirname(filename)
end

ansiblels.settings = {
  ansible = {
    ansible = {
      useFullyQualifiedCollectionNames = false,
    },
    ansibleLint = {
      arguments = "",
    },
  },
}

return ansiblels
