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
---@return function
local function openrouter_adapter(opts)
  return function()
    local openrouter = require("codecompanion.adapters.http.openrouter")

    return require("codecompanion.adapters").extend(
      openrouter,
      vim.tbl_deep_extend("force", {
        env = { api_key = get_openrouter_api_key },
      }, opts or {})
    )
  end
end

--- Returns a choices function that filters models from the given adapter.
---@param adapter_name string The adapter name
---@param filter string|fun(string, CodeCompanion.Adapter.ModelChoice):boolean A filter for model choices. Function or a pattern to match model name.
---@return function
local function model_choices(adapter_name, filter)
  if type(filter) == "string" then
    local match = filter
    ---@param name string
    ---@return boolean
    filter = function(name)
      return name:find(match) ~= nil
    end
  end

  return function(...)
    local adapter = require("codecompanion.adapters.http." .. adapter_name)
    local models = adapter.schema.model.choices(...)
    models = vim.iter(models):filter(filter):fold({}, function(acc, k, v)
      acc[k] = v
      return acc
    end)
    return models
  end
end

--- Returns a choices function that filters OpenRouter models.
---@param filter? string|fun(string, CodeCompanion.Adapter.ModelChoice):boolean A filter for model choices. Function or a string to match.
---@return function
---@diagnostic disable-next-line: unused
local function openrouter_model_choices(filter)
  return model_choices("openrouter", filter)
end
