-- Based on OpenRouter adapter with reasoning by @ernie
-- https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8

local openai = require("codecompanion.adapters.http.openai")
local log = require("codecompanion.utils.log")
local Curl = require("plenary.curl")
local config = require("codecompanion.config")
local utils = require("codecompanion.utils.adapters")
local tokens = require("codecompanion.utils.tokens")

---Remove any keys from the message that are not allowed by the API
---@param message table The message to filter
---@return table The filtered message
local function filter_message(message)
  local allowed = {
    "content",
    "role",
    "reasoning_details",
    "tool_calls",
    "tool_call_id",
  }

  for key, _ in pairs(message) do
    if not vim.tbl_contains(allowed, key) then
      message[key] = nil
    end
  end
  return message
end

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

---@class CodeCompanion.HTTPAdapter.BotHub: CodeCompanion.HTTPAdapter
return {
  name = "bothub",
  formatted_name = "BotHub",
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
    api_key = get_api_key,
    url = "https://bothub.chat/api",
    chat_url = "/v2/openai/v1/chat/completions",
    models_endpoint = "/v2/model/list?children=1",
  },
  headers = {
    ["Content-Type"] = "application/json",
    Authorization = "Bearer ${api_key}",
  },
  handlers = {
    ---@param self CodeCompanion.HTTPAdapter
    ---@return boolean
    setup = function(self)
      return openai.handlers.setup(self)
    end,

    ---Set the parameters
    ---@param self CodeCompanion.HTTPAdapter
    ---@param params table
    ---@param messages table
    ---@return table
    form_parameters = function(self, params, messages)
      return openai.handlers.form_parameters(self, params, messages)
    end,

    ---Set the format of the role and content for the messages from the chat buffer
    ---@param self CodeCompanion.HTTPAdapter.BotHub
    ---@param messages table Format is: { { role = "user", content = "Your prompt here" } }
    ---@return table
    form_messages = function(self, messages)
      local result = openai.handlers.form_messages(self, messages)

      result.messages = vim
        .iter(result.messages)
        :map(function(m)
          -- https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8#file-openrouter-lua-L200-L208
          -- Pull reasoning back out to a top-level message key
          -- https://openrouter.ai/docs/use-cases/reasoning-tokens#example-preserving-reasoning-blocks-with-openrouter-and-claude
          if m.reasoning and m.reasoning.details then
            m.reasoning_details = m.reasoning.details
          end
          m = filter_message(m)
          return m
        end)
        :totable()

      -- Prompt Caching for Claude
      local model = self.schema.model.default
      if type(model) == "function" then
        model = model(self)
      end
      if vim.startswith(model, "claude-") then
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
    ---@param self CodeCompanion.HTTPAdapter
    ---@param data table The reasoning output from the LLM
    ---@return nil|{ content: string, details: table }
    form_reasoning = function(self, data)
      local reasoning_details = {}
      local content = vim
        .iter(data)
        :map(function(item)
          if item.details and #item.details > 0 then
            for _, rd in ipairs(item.details) do
              local details = reasoning_details[rd.index + 1]
                or {
                  id = rd.id,
                  index = rd.index,
                  format = rd.format,
                  type = rd.type,
                }
              if rd.text and rd.text ~= "" then
                details.text = (details.text or "") .. rd.text
              end
              if rd.summary and rd.summary ~= "" then
                details.summary = (details.summary or "") .. rd.summary
              end
              if rd.data and rd.data ~= "" then
                details.data = (details.data or "") .. rd.data
              end
              reasoning_details[rd.index + 1] = details
            end
          end

          return item.content
        end)
        :filter(function(content)
          return content ~= nil
        end)
        :join("")

      return {
        content = content,
        details = reasoning_details,
      }
    end,

    ---Provides the schemas of the tools that are available to the LLM to call
    ---@param self CodeCompanion.HTTPAdapter
    ---@param tools table<string, table>
    ---@return table|nil
    form_tools = function(self, tools)
      return openai.handlers.form_tools(self, tools)
    end,

    ---Returns the number of tokens generated from the LLM
    ---@param self CodeCompanion.HTTPAdapter
    ---@param data table The data from the LLM
    ---@return number|nil
    tokens = function(self, data)
      return openai.handlers.tokens(self, data)
    end,

    ---Output the data from the API ready for insertion into the chat buffer
    ---@param self CodeCompanion.HTTPAdapter
    ---@param data table The streamed JSON data from the API, also formatted by the format_data handler
    ---@param tools? table The table to write any tool output to
    ---@return table|nil #[status: string, output: table]
    chat_output = function(self, data, tools)
      if not data or data == "" then
        return nil
      end

      -- Handle both streamed data and structured response
      local data_mod = type(data) == "table" and data.body or utils.clean_streamed_data(data)
      local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

      if not ok or not json.choices or #json.choices == 0 then
        return nil
      end

      -- Process tool calls from all choices
      if self.opts.tools and tools then
        for _, choice in ipairs(json.choices) do
          local delta = self.opts.stream and choice.delta or choice.message

          if delta and delta.tool_calls and #delta.tool_calls > 0 then
            for i, tool in ipairs(delta.tool_calls) do
              local tool_index = tool.index and tonumber(tool.index) or i

              -- Some endpoints like Gemini do not set this (why?!)
              local id = tool.id
              if not id or id == "" then
                id = string.format("call_%s_%s", json.created, i)
              end

              if self.opts.stream then
                local found = false
                for _, existing_tool in ipairs(tools) do
                  if existing_tool._index == tool_index then
                    -- Append to arguments if this is a continuation of a stream
                    if tool["function"] and tool["function"]["arguments"] then
                      existing_tool["function"]["arguments"] = (
                        existing_tool["function"]["arguments"] or ""
                      )
                        .. tool["function"]["arguments"]
                    end
                    found = true
                    break
                  end
                end

                if not found then
                  table.insert(tools, {
                    _index = tool_index,
                    id = id,
                    type = tool.type,
                    ["function"] = {
                      name = tool["function"]["name"],
                      arguments = tool["function"]["arguments"] or "",
                    },
                  })
                end
              else
                table.insert(tools, {
                  _index = i,
                  id = id,
                  type = tool.type,
                  ["function"] = {
                    name = tool["function"]["name"],
                    arguments = tool["function"]["arguments"],
                  },
                })
              end
            end
          end
        end
      end

      -- Process message content from the first choice
      local choice = json.choices[1]
      local delta = self.opts.stream and choice.delta or choice.message

      if not delta then
        return nil
      end

      local result = { status = "success", output = { role = delta.role } }
      if delta.content and delta.content ~= "" then
        result.output.content = delta.content
      end

      if delta.reasoning and delta.reasoning ~= "" then
        result.output.reasoning = { content = delta.reasoning }
      end

      if delta.reasoning_details and #delta.reasoning_details > 0 then
        -- We have to stash these here because Chat:add_message doesn't
        -- care about a toplevel reasoning_details key but it does carry
        -- over what's in reasoning. We put this in its rightful place
        -- in form_messages.
        result.output.reasoning = (result.output.reasoning or {})
        result.output.reasoning.details = delta.reasoning_details
      end

      return result
    end,

    ---Output the data from the API ready for inlining into the current buffer
    ---@param self CodeCompanion.HTTPAdapter
    ---@param data string|table The streamed JSON data from the API, also formatted by the format_data handler
    ---@param context? table Useful context about the buffer to inline to
    ---@return {status: string, output: table}|nil
    inline_output = function(self, data, context)
      return openai.handlers.inline_output(self, data, context)
    end,

    tools = {
      ---Format the LLM's tool calls for inclusion back in the request
      ---@param self CodeCompanion.HTTPAdapter
      ---@param tools table The raw tools collected by chat_output
      ---@return table
      format_tool_calls = function(self, tools)
        return openai.handlers.tools.format_tool_calls(self, tools)
      end,

      ---Output the LLM's tool call so we can include it in the messages
      ---@param self CodeCompanion.HTTPAdapter
      ---@param tool_call {id: string, function: table, name: string}
      ---@param output string
      ---@return table
      output_response = function(self, tool_call, output)
        return openai.handlers.tools.output_response(self, tool_call, output)
      end,
    },

    ---Function to run when the request has completed. Useful to catch errors
    ---@param self CodeCompanion.HTTPAdapter
    ---@param data? table
    ---@return nil
    on_exit = function(self, data)
      return openai.handlers.on_exit(self, data)
    end,
  },
  schema = {
    ---@type CodeCompanion.Schema
    model = {
      order = 1,
      mapping = "parameters",
      type = "enum",
      desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
      default = "kimi-k2.5",
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
          "Z.AI",
          "Minimax",
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
