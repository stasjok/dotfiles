{
  pkgs,
  helpers,
  hmConfig,
  ...
}:
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
                    api_key = helpers.mkRaw ''
                      (function()
                        local function from_file()
                          local lines = vim.F.npcall(vim.fn.readfile, "${hmConfig.xdg.configHome}/bothub/key", "", 1)
                          return lines and lines[1]
                        end
                        local api_key
                        return function()
                          api_key = vim.env.BOTHUB_API_KEY
                            or api_key
                            or from_file()
                            or vim.fn.inputsecret("Enter BotHub API key: ")
                          return api_key
                        end
                      end)()
                    '';
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

  # Mappings
  keymaps = [
    {
      mode = [
        "n"
        "v"
      ];
      key = "<Leader>o";
      action = "<Cmd>CodeCompanionActions<CR>";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<C-A>";
      action = "<Cmd>CodeCompanionChat Toggle<CR>";
    }
    {
      mode = "v";
      key = "ga";
      action = "<Cmd>CodeCompanionChat Add<CR>";
    }
  ];

  extraFiles = {
    # OpenRouter adapter with reasoning
    # https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8
    "lua/codecompanion/adapters/http/openrouter.lua".source = pkgs.fetchurl {
      url = "https://gist.github.com/ernie/e8f3a4bb2a01d3f449ec000605631eb8/raw/de6244c5fb41ad687876fb640fb94c688e23daef/openrouter.lua";
      hash = "sha256-gS2HKasKXyn5ILA/nE22SvUaWQJox+PIvBbbXmTjSVk=";
    };
  };
}
