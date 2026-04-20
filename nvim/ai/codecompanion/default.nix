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
                string.gsub(string.format("%.5f", usage.cost), "(%.%d%d%d-)0*$", "%1") or "0.00"
              )
            end
            return ""
          end
        '';
      };
      adapters = {
        http = {
          opts.show_presets = false;
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
              "claude-sonnet-4.6"
              "deepseek-v3.2"
              "elephant-alpha"
              "gemini-3-flash-preview"
              "gemini-3.1-flash-lite-preview"
              "gemini-3.1-pro-preview"
              "glm-4.5-air:free"
              "glm-5.1"
              "gpt-5.4"
              "gpt-5.4-mini"
              "gpt-5.4-nano"
              "gpt-oss-120b:free"
              "grok-4.1-fast"
              "grok-4.20"
              "kimi-k2.5"
              "mimo-v2-pro"
              "minimax-m2.5:free"
              "minimax-m2.7"
              "qwen3.6-plus"
            ]
            (name: {
              # CodeCompanion recognizes only alphanumerics and underscores in inline prompt
              # https://github.com/olimorris/codecompanion.nvim/blob/991dd81ac37b56b6d13529a08e86a42d183d79dc/lua/codecompanion/strategies/inline/init.lua#L236
              name = lib.replaceStrings [ "-" "." ":" ] [ "_" "_" "_" ] name;
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
    # BotHub adapter
    "lua/codecompanion/adapters/http/bothub.lua".text = builtins.readFile ./bothub.lua;
  };
}
