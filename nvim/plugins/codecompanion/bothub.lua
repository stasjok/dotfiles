local log = require("codecompanion.utils.log")
local Curl = require("plenary.curl")
local config = require("codecompanion.config")
local utils = require("codecompanion.utils.adapters")

local cached_models
local cache_expires
local fetch_in_progress = false

---Return a list as a set
---@param tbl table
---@return table
local function as_set(tbl)
  local set = {}
  for _, val in ipairs(tbl) do
    set[val] = true
  end
  return set
end

---Refresh the cache expiry timestamp
---@param seconds number|nil Number of seconds until the cache expires. Default: 1800
---@return number
local function set_cache_expiry(seconds)
  seconds = seconds or 1800
  cache_expires = os.time() + seconds
  return cache_expires
end

---Return cached models if the cache is still valid.
---@return table|nil
local function get_cached_models()
  if cached_models and cache_expires and cache_expires > os.time() then
    log:trace("BotHub Adapter: Using cached models")
    return cached_models
  end

  return nil
end

---Asynchronously fetch the list of available models
---@param adapter CodeCompanion.HTTPAdapter
---@return boolean
local function fetch_async(adapter)
  cached_models = get_cached_models()
  if cached_models then
    return true
  end
  if fetch_in_progress then
    return true
  end
  fetch_in_progress = true

  utils.get_env_vars(adapter)
  local url = adapter.env_replaced.url
  local models_endpoint = adapter.env_replaced.models_endpoint

  local headers = {
    ["content-type"] = "application/json",
  }

  -- Async request via plenary.curl with a callback
  local ok, err = pcall(function()
    Curl.get(url .. models_endpoint, {
      headers = headers,
      insecure = config.adapters.http.opts.allow_insecure,
      proxy = config.adapters.http.opts.proxy,
      callback = vim.schedule_wrap(function(response)
        fetch_in_progress = false

        if not response or not response.body then
          log:error(
            "Could not get the BotHub models from " .. url .. models_endpoint .. ". Empty response"
          )
          return
        end

        local ok_json, json = pcall(vim.json.decode, response.body)
        if not ok_json then
          log:error("Could not parse the response from " .. url .. models_endpoint)
          return
        end

        local models = {}
        for _, model in ipairs(json) do
          local params = as_set(model.features or {})
          if params.TEXT_TO_TEXT then
            models[model.id] = {
              opts = {
                stream = true,
                has_tools = true,
                has_vision = params.IMAGE_TO_TEXT,
                can_reason = params.REASONING or params.EFFORT,
              },
            }
          end
        end

        cached_models = models
        set_cache_expiry(config.adapters.http.opts.cache_models_for)
      end),
    })
  end)

  if not ok then
    fetch_in_progress = false
    log:error("Could not start async request for BotHub models: %s", err)
    return false
  end

  return true
end

---Fetch the list of available models synchronously.
---@param adapter CodeCompanion.HTTPAdapter
---@return table
local function fetch(adapter)
  fetch_async(adapter)

  -- Block until models are cached or timeout (milliseconds)
  local ok = vim.wait(3000, function()
    return get_cached_models() ~= nil
  end, 10)

  if not ok then
    log:error("BotHub Adapter: Timeout waiting for models")
    return {}
  end

  return cached_models or {}
end

---@param self CodeCompanion.HTTPAdapter
---@param opts? { async: boolean }
---@return table
local function get_models(self, opts)
  opts = opts or { async = true }
  local adapter = require("codecompanion.adapters.http").resolve(self)
  if not adapter then
    log:error("Could not resolve BotHub adapter in the `get_models` function")
    return {}
  end

  if not opts.async then
    return fetch(adapter)
  end

  -- Non-blocking: start async fetching (if possible) and return whatever is cached
  fetch_async(adapter)
  return get_cached_models() or {}
end

---@type string
local api_key

-- Get BotHub API key from the file
---@return string?
local function from_file()
  local path = vim.fs.joinpath(vim.fs.dirname(vim.fn.stdpath("config")), "bothub/key")
  local lines = vim.F.npcall(vim.fn.readfile, path, "", 1) --[[@as string[]?]]
  return lines and lines[1]
end

-- Get BotHub API key from various sources
---@return string
local function get_api_key()
  api_key = vim.env.BOTHUB_API_KEY
    or api_key
    or from_file()
    or vim.fn.inputsecret("Enter BotHub API key: ")
  return api_key
end

return require("codecompanion.adapters.http").extend("openrouter", {
  name = "bothub",
  formatted_name = "BotHub",
  env = {
    api_key = get_api_key,
    url = "https://bothub.chat/api",
    chat_url = "/v2/openai/v1/chat/completions",
    models_endpoint = "/v2/model/list?children=1",
  },
  schema = {
    model = {
      default = "qwen3-coder",
      choices = get_models,
    },
  },
})
