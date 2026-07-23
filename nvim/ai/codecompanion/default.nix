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
                defaultModel = "moonshotai/kimi-k2.6";
                providers = [
                  "OpenAI"
                  "Anthropic"
                  "xAI"
                  "Minimax"
                  "Moonshot AI"
                  "SiliconFlow"
                  "Z.AI"
                  "DeepSeek"
                  "Mistral"
                  "Xiaomi"
                  "Perplexity"
                  "Google"
                  "Amazon Bedrock"
                  "Novita"
                ];
              };
              openai = {
                name = "OpenAI";
                defaultModel = "openai/gpt-5.6-luna";
                modelFilter = "^openai/";
                providers = [ "OpenAI" ];
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
