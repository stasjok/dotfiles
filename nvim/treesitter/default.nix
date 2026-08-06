{
  config,
  lib,
  pkgs,
  ...
}:
{
  plugins.treesitter = {
    enable = true;

    highlight = {
      enable = true;
      disable = lib.nixvim.mkRaw ''
        function(_, _, ft)
          return ft:find("%.jinja2?$") or ft:find("^jinja2?%.") or vim.list_contains({
            -- Disable for filetypes for which builtin ftplugin already enables tree-sitter highlight
            "lua",
            "help",
            "query",
            "markdown",
          }, ft)
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
        wikitext = pkgs.tree-sitter.buildGrammar {
          language = "wikitext";
          version = "2026-06-30";
          src = pkgs.fetchFromGitHub {
            owner = "wikimedia";
            repo = "tree-sitter-wikitext";
            rev = "ed3827f9bde7ef77ab8ba71554d66ab2ba0b7fe2";
            hash = "sha256-fPJUoNTor2Y8HLr85Udl6U4L0TG2CNF0aUntxX3qi9Y=";
          };
          meta.homepage = "https://github.com/wikimedia/tree-sitter-wikitext";
        };
      in
      config.plugins.treesitter.package.allGrammars ++ [ wikitext ];
  };
}
