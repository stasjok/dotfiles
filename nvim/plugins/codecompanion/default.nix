{ pkgs, helpers, ... }:
{
  plugins.codecompanion = {
    enable = true;
    settings = {
      strategies = {
        chat.adapter = "bothub";
        inline.adapter = "bothub";
        cmd.adapter = "bothub";
      };
      adapters = {
        http = {
          opts = {
            show_defaults = false;
            # Default 'opts' are lost when 'show_defaults = false'
            show_model_choices = true;
          };
          bothub = helpers.mkRaw ''
            function()
              return require("codecompanion.adapters").extend("openrouter",${
                helpers.toLuaObject {
                  name = "bothub";
                  formatted_name = "BotHub";
                  env = {
                    api_key = "BOTHUB_API_KEY";
                    url = "https://bothub.chat/api";
                    chat_url = "/v2/openai/v1/chat/completions";
                    models_endpoint = "/v2/model/list?children=1";
                  };
                  schema.model = {
                    default = "qwen3-coder";
                    choices = helpers.mkRaw ''
                      (function()
                        ${builtins.readFile ./get_models.lua}
                      end)()
                    '';
                  };
                }
              })
            end
          '';
        };
        acp.opts.show_defaults = false;
      };
    };
  };
  extraFiles = {
    # OpenRouter adapter with reasoning
    # https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8
    "lua/codecompanion/adapters/http/openrouter.lua".source = pkgs.fetchurl {
      url = "https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8/raw/de6244c5fb41ad687876fb640fb94c688e23daef/openrouter.lua";
      hash = "sha256-gS2HKasKXyn5ILA/nE22SvUaWQJox+PIvBbbXmTjSVk=";
    };
  };
}
