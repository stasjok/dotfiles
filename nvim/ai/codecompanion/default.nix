{ lib, myLib, ... }:
let
  inherit (lib.nixvim) mkRaw toLuaObject;
in
{
  plugins.codecompanion = {
    enable = true;
    settings = {
      interactions = {
        chat = {
          adapter = "openai";
          keymaps.send.modes = {
            i = [
              "<C-S>"
              "<C-J>"
            ];
            n = [
              "<C-S>"
              "<C-J>"
            ];
          };
        };
        inline.adapter = "openai";
        cmd.adapter = "openai";
        background.adapter = {
          name = "xiaomi";
          model = "xiaomi/mimo-v2.5";
        };
        shared.keymaps = {
          always_accept.modes.n = "<LocalLeader>A";
          accept_change.modes.n = "<LocalLeader>a";
          reject_change.modes.n = "<LocalLeader>r";
          cancel.modes.n = "<LocalLeader>c";
        };
      };

      display.chat = {
        show_header_separator = true;
        window = {
          width = 0;
          opts = {
            number = false;
            relativenumber = false;
            signcolumn = "auto";
            list = false;
          };
        };
        # Enable wrap in debug window
        floating_window.opts.wrap = true;
      };

      adapters = {
        http = {
          opts.show_presets = false;
          tavily = mkRaw ''
            function()
              return require("codecompanion.adapters.http").extend("tavily", ${
                toLuaObject {
                  env.api_key = mkRaw ''get_api_key("tavily", "TAVILY_API_KEY")'';
                }
              })
            end
          '';
        }
        # OpenRouter adapters
        //
          lib.flip builtins.mapAttrs
            {
              openrouter = {
                name = "OpenRouter";
                defaultModel = "openai/gpt-5.6-terra";
                providers = {
                  order = [
                    "openai"
                    "anthropic"
                    "xai"
                    "minimax"
                    "moonshotai"
                    "decart"
                    "z-ai"
                    "deepseek"
                    "mistral"
                    "xiaomi"
                    "perplexity"
                    "google-ai-studio"
                    "amazon-bedrock"
                    "novita"
                  ];
                  data_collection = "deny";
                };
              };
              anthropic = {
                name = "Anthropic";
                defaultModel = "anthropic/claude-sonnet-5";
                modelFilter = "^anthropic/";
                providers.order = [ "anthropic" ];
              };
              deepseek = {
                name = "DeepSeek";
                defaultModel = "deepseek/deepseek-v4-flash-0731";
                modelFilter = "^deepseek/";
                providers = {
                  order = [
                    "deepseek"
                    "novita"
                    "gmicloud"
                  ];
                  data_collection = "allow";
                };
              };
              google = {
                name = "Google";
                defaultModel = "google/gemini-3.6-flash";
                modelFilter = "^google/";
                providers.order = [ "google-ai-studio" ];
              };
              kimi = {
                name = "Kimi";
                defaultModel = "moonshotai/kimi-k3";
                modelFilter = "^moonshotai/";
                providers.order = [
                  "siliconflow"
                  "moonshotai"
                ];
              };
              minimax = {
                name = "Minimax";
                defaultModel = "minimax/minimax-m3";
                modelFilter = "^minimax/";
                providers.order = [
                  "minimax"
                  "novita"
                ];
              };
              nvidia = {
                name = "NVIDIA";
                defaultModel = "nvidia/nemotron-3-ultra-550b-a55b:free";
                modelFilter = "^nvidia/";
                providers.order = [ "nvidia" ];
              };
              openai = {
                name = "OpenAI";
                defaultModel = "openai/gpt-5.6-luna";
                modelFilter = "^openai/";
                providers.order = [ "openai" ];
              };
              tencent = {
                name = "Tencent";
                defaultModel = "tencent/hy3";
                modelFilter = "^tencent/";
                providers.order = [
                  "tencent"
                  "novita"
                ];
              };
              qwen = {
                name = "Qwen";
                defaultModel = "qwen/qwen3.7-plus";
                modelFilter = "^qwen/";
                providers.order = [ "alibaba" ];
              };
              xai = {
                name = "xAI";
                defaultModel = "x-ai/grok-4.5";
                modelFilter = "^x-ai/";
                providers.order = [ "xai" ];
              };
              xiaomi = {
                name = "Xiaomi";
                defaultModel = "xiaomi/mimo-v2.5-pro";
                modelFilter = "^xiaomi/";
                providers.order = [ "xiaomi" ];
              };
              zai = {
                name = "Z.AI";
                defaultModel = "z-ai/glm-5.2";
                modelFilter = "^z-ai/";
                providers.order = [
                  "decart"
                  "novita"
                  "z-ai"
                ];
              };
            }
            (
              name: opts:
              mkRaw ''
                openrouter_adapter(${
                  toLuaObject {
                    inherit name;
                    formatted_name = opts.name or name;
                    schema = {
                      model = {
                        default = opts.defaultModel;
                        choices =
                          if opts ? modelFilter then
                            mkRaw "openrouter_model_choices(${toLuaObject opts.modelFilter})"
                          else
                            null;
                      };
                      provider.default = opts.providers or null;
                    };
                  }
                })
              ''

            );
        acp.opts.show_presets = false;
      };
    };

    luaConfig = myLib.wrapDoLuaConfig {
      pre = ./pre.lua;
      post = ./post.lua;
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
      key = "<C-Q>";
      action = "<Cmd>CodeCompanionChat Toggle<CR>";
    }
    {
      mode = "v";
      key = "ga";
      action = "<Cmd>CodeCompanionChat Add<CR>";
    }
  ];
}
