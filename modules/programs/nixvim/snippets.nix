{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) attrsOf listOf submodule;

  cfg = config.snippets;

  jsonFormat = pkgs.formats.json { };
  listOrStr = with lib.types; coercedTo str lib.singleton (listOf str);

  # A submodule type for VS Code snippets
  vscodeSnippet = submodule (
    { config, ... }:
    {
      freeformType = jsonFormat.type;
      options = {
        prefix = mkOption {
          description = "Snippet prefix";
          type = listOrStr;
        };
        body = mkOption {
          description = "Snippet body";
          type = listOrStr;
        };
        description = mkOption {
          description = "Snippet description";
          type = listOrStr;
          default = config.prefix;
        };
      };
    }
  );

  # Generate VS Code snippet files and package.json
  vscodeSnippets = lib.imap1 (idx: contrib: rec {
    inherit (contrib) language;
    path = "${toString idx}-${builtins.head contrib.language}.json";
    drv = jsonFormat.generate path contrib.snippets;
  }) cfg.vscode;
  packageJsonFile = jsonFormat.generate "package.json" {
    contributes = {
      snippets = map (contrib: { inherit (contrib) language path; }) vscodeSnippets;
    };
  };
  vscodeSnippetFiles = builtins.catAttrs "drv" vscodeSnippets;
  vscodeSnippetsDrv = pkgs.linkFarmFromDrvs "vscode-snippets" (
    [ packageJsonFile ] ++ vscodeSnippetFiles
  );
in
{
  options.snippets = {
    enable = mkEnableOption "snippets";

    vscode = mkOption {
      type = listOf (submodule {
        options = {
          language = mkOption {
            type = listOrStr;
            description = "Language(s) for these snippets";
          };
          snippets = mkOption {
            type = attrsOf vscodeSnippet;
            default = { };
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

    plugins.luasnip.fromVscode = mkIf (cfg.vscode != [ ]) [
      { paths = vscodeSnippetsDrv; }
    ];
  };
}
