local util = require("lspconfig.util")

local ansiblels = {}

ansiblels.filetypes = { "yaml.ansible" }

ansiblels.root_dir = function(filename)
  return util.root_pattern("ansible.cfg", ".git")(filename) or util.path.dirname(filename)
end

local is_at_work = vim.env.USER == "admAsunkinSS"

ansiblels.settings = {
  ansible = {
    ansible = {
      useFullyQualifiedCollectionNames = not is_at_work,
    },
    python = {
      interpreterPath = "python3",
    },
    completion = {
      provideRedirectModules = is_at_work,
      provideModuleOptionAliases = true,
    },
  },
}

return ansiblels
