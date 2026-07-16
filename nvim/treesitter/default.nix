{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.plugins.treesitter;
in
{
  plugins.treesitter = {
    enable = true;

    highlight = {
      enable = true;
      disable = lib.nixvim.mkRaw ''
        function(_, _, ft)
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
