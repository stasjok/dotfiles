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
  vscodeSnippetType = submodule {
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

  # Generate snippet files and package.json
  vscodeSnippets = lib.imap1 (idx: contrib: rec {
    inherit (contrib) language;
    path = "${builtins.head contrib.language}-${toString idx}.json";
    drv = jsonFormat.generate path contrib.snippets;
  }) cfg.vscode;

  packageJsonFile = jsonFormat.generate "package.json" {
    contributes = {
      snippets = map (contrib: { inherit (contrib) language path; }) vscodeSnippets;
    };
  };

  snippetFiles = builtins.catAttrs "drv" vscodeSnippets;

  vscodeSnippetsDrv = pkgs.linkFarmFromDrvs "vscode-snippets" ([ packageJsonFile ] ++ snippetFiles);
in
{
  options.snippets = {
    enable = mkEnableOption "snippets";

    vscode = mkOption {
      type = listOf (submodule {
        options = {
          language = mkOption {
            type = listOf str;
            description = "Language(s) for these snippets";
          };
          snippets = mkOption {
            type = attrsOf vscodeSnippetType;
            description = "Snippets for this language";
          };
        };
      });
      default = [ ];
      description = "VSCode-style snippets";
    };

    build.vscode = mkOption {
      type = lib.types.package;
      description = "VSCode snippets derivation";
      readOnly = true;
      internal = true;
    };
  };
  config = mkIf cfg.enable {
    snippets.build.vscode = vscodeSnippetsDrv;

    plugins.luasnip.fromVscode = mkIf config.plugins.luasnip.enable [
      { paths = vscodeSnippetsDrv; }
    ];
  };
}
