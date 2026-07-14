{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.plugins.treesitter;
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.treesitter = {
    enable = true;

    # TODO: Migrate to nvim-treesitter main branch
    package = pkgs.vimPlugins.nvim-treesitter-legacy;

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
        # Disable <CR> mapping in |command-line-window|
        disable = mkRaw ''
          function()
            return vim.fn.win_gettype() == "command"
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
      let
        tree-sitter-jinja2 = pkgs.tree-sitter.buildGrammar {
          language = "jinja2";
          version = "0.0.0+rev=3fa73cd";
          src = pkgs.fetchFromGitHub {
            owner = "theHamsta";
            repo = "tree-sitter-jinja2";
            rev = "3fa73cd4a871bf88e95d61adc8e66e7fb09016a1";
            hash = "sha256-LhyWfhtS1M+5m3wVnlHkM7e0yAG+Cfb1iBS1QuslG/c=";
          };
        };
      in
      cfg.package.allGrammars ++ [ tree-sitter-jinja2 ];
  };
}
