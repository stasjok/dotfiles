{
  pkgs,
  lib,
  helpers,
  ...
}:
{
  plugins.codecompanion = {
    enable = true;
    settings = {
      strategies = {
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
              "<CR>"
            ];
          };
        };
        inline.adapter = "bothub";
        cmd.adapter = "bothub";
      };
      display.chat = {
        window = {
          opts = {
            number = false;
            relativenumber = false;
          };
        };
        # Enable wrap in debug window
        child_window.opts.wrap = true;
        # but disable in diff window (not used in super diff window unfortunately)
        diff_window.opts.wrap = false;
      };
      adapters = {
        http = {
          opts = {
            show_defaults = false;
            # Default 'opts' are lost when 'show_defaults = false'
            show_model_choices = true;
          };
          bothub = "bothub";
        }
        // builtins.listToAttrs (
          lib.flip map
            [
              "claude-haiku-4.5"
              "claude-sonnet-4.5"
              "deepseek-r1-0528"
              "deepseek-v3.1-terminus"
              "gemini-2.5-flash"
              "gemini-2.5-pro"
              "glm-4.6"
              "gpt-5"
              "gpt-5-codex"
              "gpt-5-mini"
              "gpt-oss-120b"
              "grok-4"
              "grok-4-fast"
              "grok-code-fast-1"
              "kimi-k2-0905"
              "kimi-k2-thinking"
              "minimax-m2"
              "qwen3-235b-a22b-2507"
              "qwen3-coder"
              "qwen3-max"
            ]
            (name: {
              # CodeCompanion recognizes only alphanumerics and underscores in inline prompt
              # https://github.com/olimorris/codecompanion.nvim/blob/991dd81ac37b56b6d13529a08e86a42d183d79dc/lua/codecompanion/strategies/inline/init.lua#L236
              name = lib.replaceStrings [ "-" "." ] [ "_" "_" ] name;
              value = helpers.mkRaw ''
                require("codecompanion.adapters.http").extend("bothub", ${
                  helpers.toLuaObject {
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
      action = helpers.mkRaw ''
        function()
          require("codecompanion").toggle({ window_opts = { width = "auto" }})
        end
      '';
      options.desc = "CodeCompanionChat Toggle";
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
    # BotHub adapter based on OpenRouter above
    "lua/codecompanion/adapters/http/bothub.lua".text = builtins.readFile ./bothub.lua;
  };
}
