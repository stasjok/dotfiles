{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        list.selection.preselect = false;
        menu = {
          max_height = 20;
          border = "none";
          draw.columns = [
            (
              lib.nixvim.listToUnkeyedAttrs [ "label" ]
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
        };
        # These language servers are smart enough
        accept.auto_brackets.blocked_filetypes = [
          "go"
          "rust"
        ];
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 50;
          window.border = "padded";
        };
      };
      cmdline.completion = {
        menu.auto_show = true;
        list.selection.preselect = false;
      };

      # Providers
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

      # Snippets
      snippets.preset = "luasnip";

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
        "<C-Space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-E>" = [
          "hide"
          "fallback"
        ];
        "<C-I>" = [
          "select_and_accept"
          "fallback"
        ];
        "<C-P>" = [
          "select_prev"
          "fallback_to_mappings"
        ];
        "<C-N>" = [
          "select_next"
          "fallback_to_mappings"
        ];
        "<C-U>" = [
          "scroll_documentation_up"
          "fallback"
        ];
        "<C-D>" = [
          "scroll_documentation_down"
          "fallback"
        ];
        "<C-K>" = [
          "show_signature"
          "hide_signature"
          "fallback_to_mappings"
        ];
      };
      cmdline.keymap = {
        preset = "inherit";
        "<C-U>" = false;
        "<C-D>" = false;
        "<C-K>" = false;
      };
    };
  };

  performance.combinePlugins.pathsToLink = [ "/target/release" ];
}
