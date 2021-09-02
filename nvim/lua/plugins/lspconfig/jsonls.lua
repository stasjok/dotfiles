local path = require("lspconfig.util").path

local jsonls = {}

---Get a URI for local json schema
---@param name string A filename of json schema from schemas directory
---@return string #A URI to json schema
local function get_schema_path(name)
  return vim.uri_from_fname(path.join(vim.fn.stdpath("config"), "schemas", name))
end

jsonls.settings = {
  json = {
    schemas = {
      {
        fileMatch = {
          "/nvim/snippets/*.json",
          "!package.json",
        },
        url = get_schema_path("snippets.json"),
      },
    },
  },
}

return jsonls
