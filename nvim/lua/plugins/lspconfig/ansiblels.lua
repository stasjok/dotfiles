local util = require("lspconfig.util")

local ansiblels = {}

ansiblels.filetypes = { "yaml.ansible" }

ansiblels.root_dir = function(filename)
  return util.root_pattern("ansible.cfg", ".git")(filename) or util.path.dirname(filename)
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
