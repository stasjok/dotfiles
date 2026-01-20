{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        list.selection.preselect = false;
        menu = {
          max_height = 20;
          draw = {
            columns = [
              [ "kind_icon" ]
              (
                lib.nixvim.listToUnkeyedAttrs [ "label" ]
                // {
                  gap = 1;
                }
              )
              [ "source_name" ]
            ];
            components.kind_icon = {
              text = mkRaw ''
                function(ctx)
                  if ctx.source_id ~= "path" then
                    local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                    return kind_icon
                  end

                  local is_unknown_type = vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, ctx.item.data.type)
                  local mini_icon, _ = require("mini.icons").get(
                    is_unknown_type and "os" or ctx.item.data.type,
                    is_unknown_type and "" or ctx.label
                  )

                  return (mini_icon or ctx.kind_icon) .. ctx.icon_gap
                end
              '';
              highlight = mkRaw ''
                function(ctx)
                  if ctx.source_id ~= "path" then return ctx.kind_hl end

                  local is_unknown_type = vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, ctx.item.data.type)
                  local mini_icon, mini_hl = require("mini.icons").get(
                    is_unknown_type and "os" or ctx.item.data.type,
                    is_unknown_type and "" or ctx.label
                  )
                  return mini_icon ~= nil and mini_hl or ctx.kind_hl
                end
              '';
            };
          };
        };
        # These language servers are smart enough
        accept.auto_brackets.blocked_filetypes = [
          "go"
          "rust"
        ];
      };

      # Signature help
      signature = {
        enabled = true;
        trigger = {
          show_on_trigger_character = true;
          show_on_insert_on_trigger_character = false;
          show_on_accept_on_trigger_character = true;
        };
        window = {
          max_height = 15;
          show_documentation = false;
          scrollbar = true;
        };
      };

      # Cmdline ccompletion
      cmdline = {
        completion = {
          menu.auto_show = true;
          list.selection.preselect = false;
        };
      };

      # Providers
      sources.providers = {
        buffer.name = "[Buff]";
        buffer.opts.get_bufnrs = mkRaw ''
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
          "fallback"
        ];
        "<C-N>" = [
          "select_next"
          "fallback"
        ];
        "<C-U>" = [
          "scroll_documentation_up"
          "scroll_signature_up"
          "fallback"
        ];
        "<C-D>" = [
          "scroll_documentation_down"
          "scroll_signature_down"
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
