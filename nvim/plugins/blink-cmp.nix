{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        list.selection.preselect = false;
        menu.max_height = 20;
        menu.draw.columns = [
          (
            lib.nixvim.listToUnkeyedAttrs [
              "label"
              "label_description"
            ]
            // {
              gap = 1;
            }
          )
          [
            "kind_icon"
            "kind"
          ]
          [ "source_name" ]
        ];
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 50;
        };
      };
      cmdline.completion = {
        menu.auto_show = true;
        list.selection.preselect = false;
      };

      sources.providers = {
        buffer.name = "[Buff]";
        buffer.opts.get_bufnrs = lib.nixvim.mkRaw ''
          function()
            local api = vim.api
            return vim.tbl_filter(function(buf)
              return api.nvim_get_option_value("buflisted", {buf = buf})
                and api.nvim_get_option_value("buftype", {buf = buf}) == ""
            end, api.nvim_list_bufs())
          end
        '';
        cmdline.name = "[Cmd]";
        lsp.name = "[LSP]";
        path.name = "[Path]";
        snippets.name = "[Snip]";
      };

      # Appearance
      appearance = {
        nerd_font_variant = "normal";
        kind_icons = {
          Array = "";
          Boolean = "";
          Class = "󰊾";
          Color = "";
          Constant = "";
          Constructor = "";
          Enum = "󰕘";
          EnumMember = "󰕚";
          Event = "";
          Field = "";
          File = "󰈙";
          Folder = "󰝰";
          Function = "";
          Interface = "";
          Key = "󰌋";
          Keyword = "󰌈";
          Method = "󰡱";
          Module = "";
          Namespace = "";
          Null = "󰟢";
          Number = "󰎠";
          Object = "󰅩";
          Operator = "";
          Package = "";
          Property = "";
          Reference = "";
          Snippet = "󰘌";
          String = "";
          Struct = "";
          Text = "";
          TypeParameter = "󰊄";
          Unit = "";
          Value = "󱗽";
          Variable = "󰯍";
        };
      };

      # Mappings
      keymap = {
        preset = "none";
        "<C-N>" = [
          "select_next"
          "fallback"
        ];
        "<C-P>" = [
          "select_prev"
          "fallback"
        ];
        "<Tab>" = [
          "select_next"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "fallback"
        ];
        "<CR>" = [
          "accept"
          "fallback"
        ];
        "<C-Y>" = [
          "accept"
          "show"
        ];
        "<C-E>" = [ "hide" ];
        "<M-d>" = [ "scroll_documentation_down" ];
        "<M-u>" = [ "scroll_documentation_up" ];
      };
      cmdline.keymap = {
        preset = "inherit";
        "<CR>" = false;
        "<M-d>" = false;
        "<M-u>" = false;
      };
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
