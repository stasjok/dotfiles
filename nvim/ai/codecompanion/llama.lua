local adapter_utils = require("codecompanion.adapters.utils")
local config = require("codecompanion.config")

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
    can_reason = true,
    can_use_tools = true,
    can_form_structured_outputs = true,
    has_vision = has_vision,
  }

  return model.id,
    {
      formatted_name = string.lower(model.id),
      meta = context_window and { context_window = context_window } or nil,
      opts = opts,
    }
end

local models_source = {
  name = "llamacpp",
  ---@param adapter CodeCompanion.HTTPAdapter
  ---@return string
  url = function(adapter)
    if not adapter.env_replaced then
      adapter_utils.get_env_vars(adapter, { timeout = config.adapters.opts.cmd_timeout })
    end
    return adapter.env_replaced.url .. "/v1/models"
  end,
  ---@param adapter CodeCompanion.HTTPAdapter
  ---@return table
  headers = function(adapter)
    if not adapter.env_replaced then
      adapter_utils.get_env_vars(adapter, { timeout = config.adapters.opts.cmd_timeout })
    end
    return adapter_utils.set_env_vars(adapter, adapter.headers)
  end,
  transform = transform_from_llamacpp,
}

return require("codecompanion.adapters").extend("openai_legacy", {
  name = "llama.cpp",
  formatted_name = "llama.cpp",
  opts = {
    documents = false,
  },
  url = "${url}/v1/chat/completions",
  env = {
    url = function()
      return vim.env.LLAMACPP_HOST or "http://localhost:9931"
    end,
    api_key = "LLAMACPP_API_KEY",
  },
  handlers = {
    ---@param self CodeCompanion.HTTPAdapter
    ---@return boolean
    setup = function(self)
      -- Ask llama.cpp to return token usage
      if self.opts and self.opts.stream then
        self.parameters.stream_options = { include_usage = true }
      end
      return require("codecompanion.adapters.http.openrouter").handlers.setup(self)
    end,
    ---@param self CodeCompanion.HTTPAdapter
    ---@param messages table Format is: { { role = "user", content = "Your prompt here" } }
    form_messages = function(self, messages)
      local result =
        require("codecompanion.adapters.http.openai_legacy").handlers.form_messages(self, messages)
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
    form_reasoning = function(self, data)
      return require("codecompanion.adapters.http.deepseek").handlers.request.build_reasoning(
        self,
        { data = data }
      )
    end,
    parse_message_meta = function(self, data)
      return require("codecompanion.adapters.http.deepseek").handlers.response.parse_meta(
        self,
        { data = data }
      )
    end,
  },
  schema = {
    model = {
      default = "default",
      choices = function(self, opts)
        return require("codecompanion.adapters.utils.models.fetch").get(models_source, self, opts)
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
})
