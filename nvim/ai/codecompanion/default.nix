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
          adapter = "openrouter";
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
        inline.adapter = "openrouter";
        cmd.adapter = "openrouter";
        background.adapter = "openrouter";
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
        // builtins.listToAttrs (
          lib.flip map
            [
              "anthropic/claude-haiku-4.5"
              "anthropic/claude-sonnet-4.6"
              "deepseek/deepseek-v3.2"
              "openrouter/elephant-alpha"
              "google/gemini-3-flash-preview"
              "google/gemini-3.1-flash-lite-preview"
              "google/gemini-3.1-pro-preview"
              "z-ai/glm-4.5-air:free"
              "z-ai/glm-5.1"
              "openai/gpt-5.4"
              "openai/gpt-5.4-mini"
              "openai/gpt-5.4-nano"
              "openai/gpt-oss-120b:free"
              "x-ai/grok-4.1-fast"
              "x-ai/grok-4.20"
              "moonshotai/kimi-k2.5"
              "xiaomi/mimo-v2-pro"
              "minimax/minimax-m2.5:free"
              "minimax/minimax-m2.7"
              "qwen/qwen3.6-plus"
            ]
            (
              model:
              let
                name = baseNameOf model;
              in
              {
                # CodeCompanion recognizes only alphanumerics and underscores in inline prompt
                # https://github.com/olimorris/codecompanion.nvim/blob/991dd81ac37b56b6d13529a08e86a42d183d79dc/lua/codecompanion/strategies/inline/init.lua#L236
                name = lib.replaceStrings [ "-" "." ":" ] [ "_" "_" "_" ] name;
                value = mkRaw ''
                  openrouter_adapter(${
                    toLuaObject {
                      name = name;
                      formatted_name = name;
                      schema.model.default = model;
                    }
                  })
                '';
              }
            )
        )
        # OpenRouter adapters
        //
          lib.flip builtins.mapAttrs
            {
              openrouter = {
                name = "OpenRouter";
                defaultModel = "z-ai/glm-5.2";
                providers = {
                  order = [
                    "openai"
                    "anthropic"
                    "xai"
                    "minimax"
                    "moonshotai"
                    "siliconflow"
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
                defaultModel = "deepseek/deepseek-v4-pro";
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
                providers.order = [ "moonshotai" ];
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
              openai = {
                name = "OpenAI";
                defaultModel = "openai/gpt-5.6-luna";
                modelFilter = "^openai/";
                providers.order = [ "openai" ];
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
