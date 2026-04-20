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
      };
      display.chat = {
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
        show_token_count = true;
        token_count = mkRaw ''
          function(usage, adapter)
            if type(usage) == "number" then
              return (" (%d tokens)"):format(usage)
            elseif type(usage) == "table" then
              return (" (%d/%d -> %d, $%s)"):format(
                usage.prompt or 0,
                usage.cached or 0,
                usage.completion or 0,
                string.gsub(string.format("%.5f", usage.cost or 0), "(%.%d%d%d-)0*$", "%1")
              )
            end
            return ""
          end
        '';
      };
      adapters = {
        http = {
          opts.show_presets = false;
          openrouter = "openrouter";
          bothub = mkRaw ''
            require("codecompanion.adapters.http").extend("openrouter", ${
              toLuaObject {
                name = "bothub";
                formatted_name = "BotHub";
                schema.model.default = "qwen3.6-plus";
                env = {
                  url = "https://bothub.chat/api";
                  chat_url = "/v2/openai/v1/chat/completions";
                  models_endpoint = "/v2/model/list?children=1";
                  api_key = mkRaw ''require("helpers.codecompanion").get_api_key("bothub", "BOTHUB_API_KEY")'';
                };
              }
            })
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
                  require("codecompanion.adapters.http").extend("openrouter", ${
                    toLuaObject {
                      name = name;
                      formatted_name = name;
                      schema.model.default = model;
                    }
                  })
                '';
              }
            )
        );
        acp.opts.show_presets = false;
      };
    };

    luaConfig.post = myLib.readWrapDo ./post.lua;
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

  extraFiles = {
    # Helpers
    "lua/helpers/codecompanion.lua".text = builtins.readFile ./helpers.lua;
    # OpenRouter adapter
    "lua/codecompanion/adapters/http/openrouter.lua".text = builtins.readFile ./openrouter.lua;
  };
}
