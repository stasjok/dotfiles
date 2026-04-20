-- OpenRouter adapter with reasoning, model caching, and session support
local helpers = require("helpers.codecompanion")
local openai = require("codecompanion.adapters.http.openai")
local log = require("codecompanion.utils.log")
local Curl = require("plenary.curl")
local config = require("codecompanion.config")
local utils = require("codecompanion.utils.adapters")
local tokens = require("codecompanion.utils.tokens")

---Remove any keys from the message that are not allowed by the API
---@param message {[string]: any} The message to filter
---@return table The filtered message
local function filter_message(message)
  local allowed = {
    content = true,
    role = true,
    reasoning_details = true,
    tool_calls = true,
    tool_call_id = true,
  }

  for key, _ in pairs(message) do
    if not allowed[key] then
      message[key] = nil
    end
  end
  return message
end

local cached_models = {}
local cache_expires = {}
local fetch_in_progress = {}

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
---@param url string
---@param seconds number|nil Number of seconds until the cache expires. Default: 1800
---@return number
local function set_cache_expiry(url, seconds)
  seconds = seconds or 1800
  cache_expires[url] = os.time() + seconds
  return cache_expires[url]
end

---Return cached models if the cache is still valid.
---@param url string
---@return table|nil
local function get_cached_models(url)
  if cached_models[url] and cache_expires[url] and cache_expires[url] > os.time() then
    return cached_models[url]
  end

  return nil
end

---Asynchronously fetch the list of available models
---@param url string
---@param name string
---@return boolean
local function fetch_async(url, name)
  local cached = get_cached_models(url)
  if cached then
    return true
  end
  if fetch_in_progress[url] then
    return true
  end

  local headers = {
    ["content-type"] = "application/json",
  }

  fetch_in_progress[url] = true

  -- Async request via plenary.curl with a callback
  local ok, err = pcall(function()
    Curl.get(url, {
      headers = headers,
      insecure = config.adapters.http.opts.allow_insecure,
      proxy = config.adapters.http.opts.proxy,
      callback = vim.schedule_wrap(function(response)
        fetch_in_progress[url] = false

        if not response or not response.body then
          log:error("Could not get the " .. name .. " models from " .. url .. ". Empty response")
          return
        end

        local ok_json, json = pcall(vim.json.decode, response.body)
        if not ok_json then
          log:error("Could not parse the response from " .. url)
          return
        end

        local models = {}
        if url:find("/v2/model/list", 1, true) then
          -- BotHub API model list
          for _, model in ipairs(json) do
            local params = as_set(model.features or {})
            if params.TEXT_TO_TEXT then
              models[model.id] = {
                opts = {
                  has_vision = params.IMAGE_TO_TEXT,
                  can_reason = params.REASONING or params.EFFORT,
                },
              }
            end
          end
        else
          for _, model in ipairs(json.data) do
            local params = as_set(model.supported_parameters or {})
            local inputs = as_set((model.architecture or {}).input_modalities or {})
            if params.tools then
              models[model.id] = {
                opts = {
                  has_vision = inputs.image,
                  can_reason = params.reasoning,
                },
              }
            end
          end
        end

        cached_models[url] = models
        set_cache_expiry(url, config.adapters.http.opts.cache_models_for)
      end),
    })
  end)

  if not ok then
    fetch_in_progress[url] = false
    log:error("Could not start async request for " .. name .. " models: %s", err)
    return false
  end

  return true
end

---Fetch the list of available models synchronously.
---@param url string
---@param name string
---@return table
local function fetch(url, name)
  fetch_async(url, name)

  -- Block until models are cached or timeout (milliseconds)
  local ok = vim.wait(3000, function()
    return get_cached_models(url) ~= nil
  end, 10)

  if not ok then
    log:error(name .. " adapter: Timeout waiting for models")
    return {}
  end

  return get_cached_models(url) or {}
end

---@param self CodeCompanion.HTTPAdapter.OpenRouter
---@param opts? { async: boolean }
---@return table
local function get_models(self, opts)
  opts = opts or { async = true }
  local adapter = require("codecompanion.adapters.http").resolve(self)
  if not adapter then
    log:error(
      "Could not resolve " .. self.formatted_name .. " adapter in the `get_models` function"
    )
    return {}
  end

  if not adapter.env_replaced then
    utils.get_env_vars(adapter)
  end

  local url = adapter.env.url .. adapter.env.models_endpoint
  local name = adapter.formatted_name

  if not opts.async then
    return fetch(url, name)
  end

  -- Non-blocking: start async fetching (if possible) and return whatever is cached
  fetch_async(url, name)
  return get_cached_models(url) or {}
end

---@class CodeCompanion.HTTPAdapter.OpenRouter: CodeCompanion.HTTPAdapter
return {
  name = "openrouter",
  formatted_name = "OpenRouter",
  roles = {
    llm = "assistant",
    user = "user",
    tool = "tool",
  },
  opts = {
    stream = true,
    tools = true,
    vision = true,
    cache_breakpoints = 4, -- Cache up to this many messages
    cache_over = 300, -- Cache any message which has this many tokens or more
  },
  features = {
    text = true,
    tokens = true,
  },
  url = "${url}${chat_url}",
  env = {
    api_key = helpers.get_api_key("openrouter", "OPENROUTER_API_KEY"),
    url = "https://openrouter.ai/api",
    chat_url = "/v1/chat/completions",
    models_endpoint = "/v1/models",
  },
  headers = {
    ["Content-Type"] = "application/json",
    Authorization = "Bearer ${api_key}",
  },
  available_tools = {
    ["web_search"] = {
      description = "Allow models to search the web for the latest information before generating a response.",
      enabled = true,
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param tools table The transformed tools table
      callback = function(self, tools)
        table.insert(tools, {
          type = "openrouter:web_search",
        })
      end,
    },
  },
  handlers = {
    lifecycle = {
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@return boolean
      setup = function(self)
        return openai.handlers.setup(self)
      end,

      ---Function to run when the request has completed. Useful to catch errors
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data? table
      ---@return nil
      on_exit = function(self, data)
        return openai.handlers.on_exit(self, data)
      end,
    },

    request = {
      ---Set the parameters
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param params table
      ---@param messages table
      ---@return table
      build_parameters = function(self, params, messages)
        if not self._session_id then
          local meta = _G.codecompanion_chat_metadata[vim.api.nvim_get_current_buf()]
          local chat_id = meta and meta.id or math.random(10000000)
          self._session_id = string.format("nvim-%d-chat-%d", vim.fn.getpid(), chat_id)
        end
        params.session_id = self._session_id
        return params
      end,

      ---Set the format of the role and content for the messages from the chat buffer
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param messages table Format is: { { role = "user", content = "Your prompt here" } }
      ---@return table
      build_messages = function(self, messages)
        local result = openai.handlers.form_messages(self, messages)

        result.messages = vim
          .iter(result.messages)
          :map(function(m)
            -- Pull reasoning back out to a top-level message key
            -- https://openrouter.ai/docs/use-cases/reasoning-tokens#example-preserving-reasoning-blocks-with-openrouter-and-claude
            if m.reasoning and m.reasoning.details then
              m.reasoning_details = m.reasoning.details
            end
            m = filter_message(m)
            return m
          end)
          :totable()

        -- Prompt Caching for Claude and Qwen
        local model = self.schema.model.default
        if type(model) == "function" then
          model = model(self)
        end
        if model:find("claude", 0, true) or model:find("qwen", 0, true) then
          local breakpoints_used = 0
          local is_last_text = true
          messages = result.messages
          for i = #messages, 1, -1 do
            local msgs = messages[i]
            if type(msgs.content) == "table" then
              -- Loop through the content
              for _, msg in ipairs(msgs.content) do
                if msg.type ~= "text" or msg.text == "" then
                  goto continue
                end
                if
                  tokens.calculate(msg.text) >= self.opts.cache_over
                    and breakpoints_used < self.opts.cache_breakpoints
                  or is_last_text
                then
                  msg.cache_control = { type = "ephemeral" }
                  breakpoints_used = breakpoints_used + 1
                  is_last_text = false
                end
                ::continue::
              end
            elseif type(msgs.content) == "string" then
              if
                tokens.calculate(msgs.content) >= self.opts.cache_over
                  and breakpoints_used < self.opts.cache_breakpoints
                or is_last_text
              then
                msgs.content = {
                  {
                    type = "text",
                    text = msgs.content,
                    cache_control = { type = "ephemeral" },
                  },
                }
                breakpoints_used = breakpoints_used + 1
                is_last_text = false
              end
            end
          end
          result.messages = messages
        end

        return result
      end,

      ---Form the reasoning output that is stored in the chat buffer
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data table The reasoning output from the LLM
      ---@return table
      build_reasoning = function(self, data)
        local reasoning_details = {}
        for _, item in ipairs(data) do
          for _, rd in ipairs(item.details) do
            local details = reasoning_details[rd.index + 1] or {}
            -- Common Fields
            details.id = rd.id
            details.format = rd.format
            details.index = rd.index
            -- Reasoning Detail Type
            details.type = rd.type
            -- Summary Type
            if rd.summary then
              details.summary = (details.summary or "") .. rd.summary
            end
            -- Encrypted Type
            if rd.data then
              details.data = (details.data or "") .. rd.data
            end
            -- Text Type
            if rd.text then
              details.text = (details.text or "") .. rd.text
            end
            if rd.signature then
              details.signature = (details.signature or "") .. rd.signature
            end
            -- OpenRouter often returns "reasoning.summary" or "reasoning.text" first,
            -- and then "reasoning.encrypted" with the same index
            if details.type == "reasoning.encrypted" then
              details.summary = nil
              details.text = nil
              details.signature = nil
            end
            reasoning_details[rd.index + 1] = details
          end
        end
        return {
          details = reasoning_details,
        }
      end,

      ---Provides the schemas of the tools that are available to the LLM to call
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param tools table<string, table>
      ---@return table|nil
      build_tools = function(self, tools)
        if not self.opts.tools or not tools then
          return nil
        end
        if vim.tbl_count(tools) == 0 then
          return nil
        end

        local transformed = {}
        for _, tool in pairs(tools) do
          for _, schema in pairs(tool) do
            if schema._meta and schema._meta.adapter_tool then
              if self.available_tools[schema.name] then
                self.available_tools[schema.name].callback(self, transformed)
              end
            else
              table.insert(transformed, schema)
            end
          end
        end

        return { tools = transformed }
      end,
    },

    response = {
      ---Returns detailed token usage from the LLM
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data table The data from the LLM
      ---@return table|nil
      parse_tokens = function(self, data)
        if data and data ~= "" then
          local data_mod = type(data) == "table" and data.body or utils.clean_streamed_data(data)
          local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

          if ok and json.usage then
            return {
              prompt = json.usage.prompt_tokens,
              completion = json.usage.completion_tokens,
              total = json.usage.total_tokens,
              cached = json.usage.prompt_tokens_details
                and json.usage.prompt_tokens_details.cached_tokens,
              cost = json.usage.cost,
            }
          end
        end
      end,

      ---Output the data from the API ready for insertion into the chat buffer
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data table The streamed JSON data from the API, also formatted by the format_data handler
      ---@param tools? table The table to write any tool output to
      ---@return table|nil #[status: string, output: table]
      parse_chat = function(self, data, tools)
        return openai.handlers.chat_output(self, data, tools)
      end,

      ---Process non-standard fields in the response
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data table
      ---@return table
      parse_meta = function(self, data)
        local extra = data.extra
        if not extra then
          return data
        end

        data.output.reasoning = {}

        if extra.reasoning and extra.reasoning ~= "" then
          data.output.reasoning.content = extra.reasoning
          if data.output.content == "" then
            data.output.content = nil
          end
        end

        if extra.reasoning_details and #extra.reasoning_details > 0 then
          data.output.reasoning.details = extra.reasoning_details
        end

        return data
      end,

      ---Output the data from the API ready for inlining into the current buffer
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param data string|table The streamed JSON data from the API, also formatted by the format_data handler
      ---@param context? table Useful context about the buffer to inline to
      ---@return {status: string, output: table}|nil
      parse_inline = function(self, data, context)
        return openai.handlers.inline_output(self, data, context)
      end,
    },

    tools = {
      ---Format the LLM's tool calls for inclusion back in the request
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param tools table The raw tools collected by chat_output
      ---@return table
      format_calls = function(self, tools)
        return openai.handlers.tools.format_tool_calls(self, tools)
      end,

      ---Output the LLM's tool call so we can include it in the messages
      ---@param self CodeCompanion.HTTPAdapter.OpenRouter
      ---@param tool_call {id: string, function: table, name: string}
      ---@param output string
      ---@return table
      format_response = function(self, tool_call, output)
        return openai.handlers.tools.output_response(self, tool_call, output)
      end,
    },
  },
  schema = {
    ---@type CodeCompanion.Schema
    model = {
      order = 1,
      mapping = "parameters",
      type = "enum",
      desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
      default = "openai/gpt-5.4",
      choices = get_models,
    },
    -- Source: https://github.com/olimorris/codecompanion.nvim/discussions/1013#discussioncomment-15375459
    ["reasoning.enabled"] = {
      optional = true,
      default = true,
      order = 2,
      mapping = "parameters",
      type = "boolean",
      enabled = function(self)
        local model = self.schema.model.default
        if type(model) == "function" then
          model = model()
        end
        local choices = self.schema.model.choices
        if type(choices) == "function" then
          choices = choices(self)
        end
        if vim.tbl_get(choices, model, "opts", "can_reason") then
          return true
        end
        return false
      end,
    },
    ["reasoning.effort"] = {
      optional = true,
      default = "medium",
      choices = {
        "xhigh",
        "high",
        "medium",
        "low",
        "minimal",
        "none",
      },
      order = 3,
      mapping = "parameters",
      type = "string",
      enabled = function(self)
        local model = self.schema.model.default
        if type(model) == "function" then
          model = model()
        end
        local choices = self.schema.model.choices
        if type(choices) == "function" then
          choices = choices(self)
        end
        if vim.tbl_get(choices, model, "opts", "can_reason") then
          return true
        end
        return false
      end,
    },
    temperature = {
      order = 3,
      mapping = "parameters",
      type = "number",
      optional = true,
      default = 1,
      desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
      validate = function(n)
        return n >= 0 and n <= 2, "Must be between 0 and 2"
      end,
    },
    top_p = {
      order = 4,
      mapping = "parameters",
      type = "number",
      optional = true,
      default = 1,
      desc = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.",
      validate = function(n)
        return n >= 0 and n <= 1, "Must be between 0 and 1"
      end,
    },
    stop = {
      order = 5,
      mapping = "parameters",
      type = "list",
      optional = true,
      default = nil,
      subtype = {
        type = "string",
      },
      desc = "Up to 4 sequences where the API will stop generating further tokens.",
      validate = function(l)
        return #l >= 1 and #l <= 4, "Must have between 1 and 4 elements"
      end,
    },
    max_tokens = {
      order = 6,
      mapping = "parameters",
      type = "integer",
      optional = true,
      default = nil,
      desc = "The maximum number of tokens to generate in the chat completion. The total length of input tokens and generated tokens is limited by the model's context length.",
      validate = function(n)
        return n > 0, "Must be greater than 0"
      end,
    },
    presence_penalty = {
      order = 7,
      mapping = "parameters",
      type = "number",
      optional = true,
      default = 0,
      desc = "Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.",
      validate = function(n)
        return n >= -2 and n <= 2, "Must be between -2 and 2"
      end,
    },
    frequency_penalty = {
      order = 8,
      mapping = "parameters",
      type = "number",
      optional = true,
      default = 0,
      desc = "Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.",
      validate = function(n)
        return n >= -2 and n <= 2, "Must be between -2 and 2"
      end,
    },
    logit_bias = {
      order = 9,
      mapping = "parameters",
      type = "map",
      optional = true,
      default = nil,
      desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
      subtype_key = {
        type = "integer",
      },
      subtype = {
        type = "integer",
        validate = function(n)
          return n >= -100 and n <= 100, "Must be between -100 and 100"
        end,
      },
    },
    user = {
      order = 10,
      mapping = "parameters",
      type = "string",
      optional = true,
      default = nil,
      desc = "A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. Learn more.",
      validate = function(u)
        return u:len() < 100, "Cannot be longer than 100 characters"
      end,
    },
    provider = {
      order = 11,
      mapping = "parameters",
      type = "map",
      optional = true,
      default = {
        order = {
          "OpenAI",
          "Anthropic",
          "xAI",
          "Minimax",
          "SiliconFlow",
          "Z.AI",
          "Moonshot AI",
          "DeepSeek",
          "Mistral",
          "Xiaomi",
          "Perplexity",
          "Google",
          "Amazon Bedrock",
          "Novita",
        },
        allow_fallbacks = true,
      },
      desc = "When multiple model providers are available, optionally indicate your routing preference",
    },
  },
}
