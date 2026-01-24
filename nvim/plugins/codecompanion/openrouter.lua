local openai = require("codecompanion.adapters.http.openai")
local log = require("codecompanion.utils.log")
local utils = require("codecompanion.utils.adapters")
local Curl = require("plenary.curl")
local config = require("codecompanion.config")
local _cache_expires
local _cache_file = vim.fn.tempname()
local _cached_models

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

---Get a list of available OpenRouter models
---@param self CodeCompanion.HTTPAdapter
---@return any
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
  if adapter.env_replaced.api_key then
    headers["Authorization"] = "Bearer " .. adapter.env_replaced.api_key
  end

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
      "Could not get the OpenAI compatible models from " .. url .. models_endpoint .. ".\nError: %s",
      response
    )
    return {}
  end

  ok, json = pcall(vim.json.decode, response.body)
  if not ok then
    log:error("Could not parse the response from " .. url .. models_endpoint)
    return {}
  end

  for _, model in ipairs(json.data) do
    local params = as_set(model.supported_parameters or {})
    local inputs = as_set((model.architecture or {}).input_modalities or {})
    if params.tools then
      _cached_models[model.id] = {
        opts = {
          stream = true,
          has_tools = true,
          has_vision = inputs.image,
          can_reason = params.reasoning,
        },
      }
    end
  end

  _cache_expires = utils.refresh_cache(_cache_file, config.adapters.http.opts.cache_models_for)

  return models()
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
  },
  features = {
    text = true,
    tokens = true,
  },
  url = "${url}${chat_url}",
  env = {
    api_key = "OPENROUTER_API_KEY",
    url = "https://openrouter.ai/api",
    chat_url = "/v1/chat/completions",
    models_endpoint = "/v1/models",
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
    ---@param self CodeCompanion.HTTPAdapter
    ---@param messages table Format is: { { role = "user", content = "Your prompt here" } }
    ---@return table
    form_messages = function(self, messages)
      local model = self.schema.model.default
      if type(model) == "function" then
        model = model(self)
      end

      messages = vim.tbl_map(function(m)
        if vim.startswith(model, "o1") and m.role == "system" then
          m.role = self.roles.user
        end

        -- Ensure tool_calls are clean
        if m.tool_calls then
          m.tool_calls = vim
            .iter(m.tool_calls)
            :map(function(tool_call)
              return {
                id = tool_call.id,
                ["function"] = tool_call["function"],
                type = tool_call.type,
              }
            end)
            :totable()
        end

        -- Process any images
        if m.opts and m.opts.tag == "image" and m.opts.mimetype then
          if self.opts and self.opts.vision then
            m.content = {
              {
                type = "image_url",
                image_url = {
                  url = string.format("data:%s;base64,%s", m.opts.mimetype, m.content),
                },
              },
            }
          else
            -- Remove the message if vision is not supported
            return nil
          end
        end

        -- Pull reasoning back out to a top-level message key
        -- https://openrouter.ai/docs/use-cases/reasoning-tokens#example-preserving-reasoning-blocks-with-openrouter-and-claude
        if m.reasoning and m.reasoning.details then
          m.reasoning_details = m.reasoning.details
        end

        m = filter_message(m)

        return m
      end, messages)

      return { messages = messages }
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
    ---@return table|nil [status: string, output: table]
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
      ---@type string|fun(arg: CodeCompanion.HTTPAdapter): string
      default = "x-ai/grok-code-fast-1",
      ---@type string|fun(arg: CodeCompanion.HTTPAdapter): table
      choices = function(self)
        return get_models(self)
      end,
    },
    reasoning_effort = {
      order = 2,
      mapping = "parameters",
      type = "string",
      optional = true,
      condition = function(self)
        local model = self.schema.model.default
        if type(model) == "function" then
          model = model()
        end
        local choices = self.schema.model.choices
        if type(choices) == "function" then
          choices = choices(self)
        end
        if
          choices
          and choices[model]
          and choices[model].opts
          and choices[model].opts.can_reason
        then
          return true
        end
        return false
      end,
      default = "medium",
      desc = "Constrains effort on reasoning for reasoning models. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.",
      choices = {
        "high",
        "medium",
        "low",
      },
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
  },
}