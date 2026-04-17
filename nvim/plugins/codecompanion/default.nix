{ lib, myLib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.codecompanion = {
    enable = true;
    settings = {
      interactions = {
        chat = {
          adapter = "bothub";
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
        inline.adapter = "bothub";
        cmd.adapter = "bothub";
        background.adapter = "bothub";
      };
      display.chat = {
        window = {
          width = mkRaw ''
            function()
              return math.min(math.floor(vim.o.columns / 2), 79)
            end
          '';
          opts = {
            number = false;
            relativenumber = false;
            signcolumn = "auto";
            list = false;
          };
        };
        # Enable wrap in debug window
        floating_window.opts.wrap = true;
        # but disable in diff window (not used in super diff window unfortunately)
        diff_window.opts.wrap = false;
      };
      adapters = {
        http = {
          opts = {
            show_presets = false;
            # Default 'opts' are lost when 'show_defaults = false'
            show_model_choices = true;
          };
          bothub = "bothub";
          openrouter = mkRaw ''
            require("codecompanion.adapters.http").extend("bothub", ${
              lib.nixvim.toLuaObject {
                name = "openrouter";
                formatted_name = "OpenRouter";
                schema.model.default = "moonshotai/kimi-k2.5";
                env = {
                  url = "https://openrouter.ai/api";
                  chat_url = "/v1/chat/completions";
                  models_endpoint = "/v1/models";
                  api_key_path = mkRaw ''vim.fs.joinpath(vim.fs.dirname(vim.fn.stdpath("config")), "openrouter/key")'';
                  api_key_env = "OPENROUTER_API_KEY";
                };
              }
            })
          '';
        }
        // builtins.listToAttrs (
          lib.flip map
            [
              "claude-haiku-4.5"
              "claude-sonnet-4.5"
              "deepseek-v3.2"
              "gemini-3-flash-preview"
              "gemini-3-pro-preview"
              "glm-4.7"
              "gpt-5.2"
              "gpt-5.2-codex"
              "gpt-5-mini"
              "gpt-5.1-codex-mini"
              "gpt-oss-120b"
              "grok-4"
              "grok-4.1-fast"
              "grok-code-fast-1"
              "kimi-k2.5"
              "minimax-m2.1"
              "qwen3-235b-a22b-2507"
              "qwen3-coder"
              "qwen3-max"
            ]
            (name: {
              # CodeCompanion recognizes only alphanumerics and underscores in inline prompt
              # https://github.com/olimorris/codecompanion.nvim/blob/991dd81ac37b56b6d13529a08e86a42d183d79dc/lua/codecompanion/strategies/inline/init.lua#L236
              name = lib.replaceStrings [ "-" "." ] [ "_" "_" ] name;
              value = mkRaw ''
                require("codecompanion.adapters.http").extend("bothub", ${
                  lib.nixvim.toLuaObject {
                    inherit name;
                    formatted_name = name;
                    schema.model.default = name;
                  }
                })
              '';
            })
        );
        acp.opts.show_defaults = false;
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
    # BotHub adapter
    "lua/codecompanion/adapters/http/bothub.lua".text = builtins.readFile ./bothub.lua;
  };
}
