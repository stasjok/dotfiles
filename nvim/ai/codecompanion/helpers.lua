local M = {}

-- Get API key from the file
---@param name string
---@return string?
local function key_from_file(name)
  ---@diagnostic disable-next-line: generic-constraint-mismatch
  local key_path = vim.fs.dirname(vim.fn.stdpath("config")) --[[@as string]]
  key_path = vim.fs.joinpath(key_path, "keys", name)
  local lines = vim.F.npcall(vim.fn.readfile, key_path, "", 1) --[[@as string[]?]]
  return lines and lines[1]
end

--- Factory that returns a closure for fetching API keys.
--- The closure caches the key after first successful retrieval.
---@param name string Human-readable adapter name for the prompt
---@param env_var string Environment variable name for the API key
---@return fun(adapter: table): string
function M.get_api_key(name, env_var)
  ---@type string
  local api_key

  ---@return string
  return function()
    api_key = vim.env[env_var]
      or api_key
      or key_from_file(name)
      or vim.fn.inputsecret(("Enter %s API key: "):format(name))
    return api_key
  end
end

return M
