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

--- Transform llama.cpp model list entry to CodeCompanion.Adapter.ModelChoice format
---@param model table The model entry from llama.cpp /models endpoint
---@return string id, CodeCompanion.Adapter.ModelChoice entry
function transform_from_llamacpp(model)
  -- Extract context window from status.args (--ctx-size parameter)
  local context_window = nil
  if model.status and model.status.args then
    for i, arg in ipairs(model.status.args) do
      if arg == "--ctx-size" and model.status.args[i + 1] then
        context_window = tonumber(model.status.args[i + 1])
        break
      end
    end
  end

  -- Detect vision capability from input modalities
  local has_vision = false
  if model.architecture and model.architecture.input_modalities then
    has_vision = vim.tbl_contains(model.architecture.input_modalities, "image")
  end

  local opts = {
    can_form_structured_outputs = true,
    can_use_tools = true,
    has_vision = has_vision,
  }

  return model.id,
    {
      formatted_name = string.lower(model.id),
      meta = context_window and { context_window = context_window } or nil,
      opts = opts,
    }
end

--- Factory that returns a llama.cpp adapter configuration
---@param endpoint string The llama.cpp server endpoint (e.g., "http://127.0.0.1:18081")
---@param opts? table Additional options to merge into the adapter
---@return function
local function llamacpp_adapter(endpoint, opts)
  return function()
    local adapter_utils = require("codecompanion.adapters.utils")
    local config = require("codecompanion.config")
    local fetch_models = require("codecompanion.adapters.utils.models.fetch")

    local models_source = {
      name = "llamacpp",
      url = endpoint .. "/v1/models",
      headers = function(adapter)
        adapter_utils.get_env_vars(adapter, { timeout = config.adapters.opts.cmd_timeout })
        return adapter_utils.set_env_vars(adapter, adapter.headers)
      end,
      transform = transform_from_llamacpp,
    }

    return require("codecompanion.adapters").extend(
      "openai",
      vim.tbl_deep_extend("force", {
        url = endpoint .. "/v1/chat/completions",
        env = {
          api_key = get_api_key("llama.cpp", "LLAMACPP_API_KEY"),
        },
        schema = {
          model = {
            default = "tiel-coder-35b-a3b",
            choices = function(self, opts)
              return fetch_models.get(models_source, self, opts)
            end,
          },
          reasoning_effort = {
            default = "default",
            choices = {
              "default",
              "minimal",
              "low",
              "medium",
              "high",
              "xhigh",
              "max",
            },
          },
        },
        handlers = {
          form_messages = function(self, messages)
            local result =
              require("codecompanion.adapters.http.openai").handlers.form_messages(self, messages)
            result.messages = vim
              .iter(result.messages)
              :map(function(m)
                m.reasoning_content = m.reasoning
                m.reasoning = nil
                return m
              end)
              :totable()
            return result
          end,
          form_reasoning = function(...)
            return require("codecompanion.adapters.http.deepseek").handlers.request.build_reasoning(
              ...
            )
          end,
          parse_message_meta = function(...)
            return require("codecompanion.adapters.http.deepseek").handlers.response.parse_meta(...)
          end,
        },
      }, opts or {})
    )
  end
end
