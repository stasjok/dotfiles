local util = require("lspconfig.util")

local bashls = {}

bashls.root_dir = function(filename)
  return util.find_git_ancestor(filename) or util.path.dirname(filename)
end

return bashls
