{ lib, pkgs, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.treesitter = {
    enable = true;

    settings = {
      highlight = {
        enable = true;
        disable = mkRaw ''
          function()
            local ft = vim.bo.filetype
            return ft == "yaml.ansible" or ft:find("%.jinja2?$")
          end
        '';
      };

      indent = {
        enable = true;
        disable = [
          "yaml"
          "fish"
        ];
      };

      incremental_selection = {
        enable = true;
        # Disable <CR> mapping in |command-line-window| and in codecompanion.nvim
        disable = mkRaw ''
          function()
            return vim.fn.win_gettype() == "command" or vim.bo.filetype == "codecompanion"
          end
        '';
        keymaps = {
          init_selection = "<CR>";
          node_incremental = "<CR>";
          scope_incremental = "<C-J>"; # <C-CR>
          node_decremental = "<M-CR>";
        };
      };

      # If it's set, it's prepended to 'rtp'
      parser_install_dir = null;
    };

    grammarPackages =
      pkgs.vimPlugins.nvim-treesitter.allGrammars
      ++ (with pkgs.tree-sitter.builtGrammars; [
        tree-sitter-jinja2
      ]);
  };
}
