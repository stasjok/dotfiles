--- Get API key from the file
---@param name string
---@return string?
local function key_from_file(name)
  ---@diagnostic disable-next-line: generic-constraint-mismatch
  local key_path = vim.fs.dirname(vim.fn.stdpath("config")) --[[@as string]]
  key_path = vim.fs.joinpath(key_path, "keys", name)
  ---@diagnostic disable-next-line: param-type-mismatch
  local lines = vim.F.npcall(vim.fn.readfile, key_path, "", 1) --[[@as string[]?]]
  return lines and lines[1]
end

--- Factory that returns a closure for fetching API keys.
--- The closure caches the key after first successful retrieval.
---@param name string Human-readable adapter name for the prompt
---@param env_var string Environment variable name for the API key
---@return fun(adapter: table): string
local function get_api_key(name, env_var)
  ---@type string
  local api_key

  ---@return string
  return function()
    api_key = vim.env[env_var] --[[@as string?]]
      or api_key
      or key_from_file(name)
      or vim.fn.inputsecret(("Enter %s API key: "):format(name))
    return api_key
  end
end

-- A function to use in env.api_key for OpenRouter adapter
local get_openrouter_api_key = get_api_key("openrouter", "OPENROUTER_API_KEY")

--- Returns OpenRouter adapter with my modifications
---@diagnostic disable-next-line: unused
---@param opts? table
local function openrouter_adapter(opts)
  local openrouter = require("codecompanion.adapters.http.openrouter")

  return require("codecompanion.adapters").extend(
    openrouter,
    vim.tbl_deep_extend("force", {
      env = { api_key = get_openrouter_api_key },
    }, opts or {})
  )
end

--- Returns a choices function that filters models from the given adapter.
---@param adapter CodeCompanion.HTTPAdapter The base adapter (e.g. openrouter)
---@param filter? string|fun(string, CodeCompanion.Adapter.ModelChoice):boolean A filter for model choices. Function or a string to match.
---@return function
local function model_choices(adapter, filter)
  local filter_fn = filter
  if not filter_fn then
    filter_fn = function()
      return true
    end
  elseif type(filter_fn) == "string" then
    local match = filter_fn
    ---@param name string
    ---@return boolean
    filter_fn = function(name)
      return name:find(match, 1, true) ~= nil
    end
  end

  return function(...)
    local models = adapter.schema.model.choices(...)
    models = vim.iter(models):filter(filter_fn)
    return models
  end
end

--- Returns a choices function that filters OpenRouter models.
---@param filter? string|fun(string, CodeCompanion.Adapter.ModelChoice):boolean A filter for model choices. Function or a string to match.
---@return function
---@diagnostic disable-next-line: unused
local function openrouter_model_choices(filter)
  return model_choices(require("codecompanion.adapters.http.openrouter"), filter)
end
