{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types)
    str
    listOf
    attrsOf
    submodule
    oneOf
    ;

  cfg = config.snippets;
  jsonFormat = pkgs.formats.json { };

  # Snippet submodule type
  snippetType = submodule {
    freeformType = jsonFormat.type;
    options = {
      prefix = mkOption {
        type = oneOf [
          str
          (listOf str)
        ];
        description = "Snippet prefix";
      };
      body = mkOption {
        type = oneOf [
          str
          (listOf str)
        ];
        description = "Snippet body";
      };
      description = mkOption {
        type = str;
        default = "";
        description = "Snippet description";
      };
    };
  };

  # Language snippet submodule type
  languageSnippetType = submodule {
    options = {
      language = mkOption {
        type = listOf str;
        description = "Language(s) for these snippets";
      };
      snippets = mkOption {
        type = attrsOf snippetType;
        description = "Snippets for this language";
      };
    };
  };

  # Generate package.json directory using writeTextDir
  packageDir = pkgs.writeTextDir "package.json" (
    builtins.toJSON {
      contributes = {
        snippets = map (contrib: {
          language = contrib.language;
          path = jsonFormat.generate "${builtins.head contrib.language}.json" contrib.snippets;
        }) cfg.vscode;
      };
    }
  );
in
{
  options.snippets = {
    enable = mkEnableOption "snippets";

    vscode = mkOption {
      type = listOf languageSnippetType;
      default = [ ];
      description = "VSCode-style snippets";
    };
  };

  config.plugins.luasnip.fromVscode = mkIf (cfg.enable && config.plugins.luasnip.enable) [
    { paths = packageDir; }
  ];
}
