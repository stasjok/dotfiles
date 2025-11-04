local log = require("codecompanion.utils.log")
local Curl = require("plenary.curl")
local config = require("codecompanion.config")
local utils = require("codecompanion.utils.adapters")
local _cache_expires
local _cache_file = vim.fn.tempname()
local _cached_models

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

---Return the cached models
---@return any
local function models()
  return _cached_models
end

---@param self CodeCompanion.HTTPAdapter
local function get_models(self)
  if _cached_models and _cache_expires and _cache_expires > os.time() then
    return models()
  end

  _cached_models = {}

  local adapter = require("codecompanion.adapters").resolve(self)
  if not adapter then
    log:error("Could not resolve OpenRouter adapter in the `get_models` function")
    return {}
  end

  utils.get_env_vars(adapter)
  local url = adapter.env_replaced.url
  local models_endpoint = adapter.env_replaced.models_endpoint

  local headers = {
    ["content-type"] = "application/json",
  }

  local ok, response, json

  ok, response = pcall(function()
    return Curl.get(url .. models_endpoint, {
      sync = true,
      headers = headers,
      insecure = config.adapters.http.opts.allow_insecure,
      proxy = config.adapters.http.opts.proxy,
    })
  end)
  if not ok then
    log:error(
      "Could not get the BotHub models from " .. url .. models_endpoint .. ".\nError: %s",
      response
    )
    return {}
  end

  ok, json = pcall(vim.json.decode, response.body)
  if not ok then
    log:error("Could not parse the response from " .. url .. models_endpoint)
    return {}
  end

  for _, model in ipairs(json) do
    local params = as_set(model.features or {})
    if params.TEXT_TO_TEXT then
      _cached_models[model.id] = {
        opts = {
          stream = true,
          has_tools = true,
          has_vision = params.IMAGE_TO_TEXT,
          can_reason = params.REASONING or params.EFFORT,
        },
      }
    end
  end

  _cache_expires = utils.refresh_cache(_cache_file, config.adapters.http.opts.cache_models_for)

  return models()
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
