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
          width = "auto";
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
    # BotHub adapter based on OpenRouter above
    "lua/codecompanion/adapters/http/bothub.lua".text = builtins.readFile ./bothub.lua;
  };
}
