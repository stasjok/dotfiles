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

  # A submodule for VS Code snippet
  snippet = submodule (
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
  vscodeSnippets = submodule (
    { config, ... }:
    {
      options = {
        language = mkOption {
          type = listOrStr;
          description = "Language(s) for these snippets.";
        };
        snippets = mkOption {
          type = attrsOf snippet;
          default = { };
          description = "Snippets for this language.";
        };
        source = mkOption {
          type = with lib.types; nullOr path;
          description = "Path to a VS Code snippets JSON file.";
        };
      };

      config = {
        source = mkIf (config.snippets != { }) (jsonFormat.generate "snippets.json" config.snippets);
      };
    }
  );

  # Generate VS Code snippet files and package.json
  vscodeSnippetFiles = lib.imap1 (idx: contrib: {
    inherit (contrib) language source;
    name = "${toString idx}-${builtins.head contrib.language}.json";
  }) cfg.vscode;
  packageJsonFile = jsonFormat.generate "package.json" {
    contributes = {
      snippets = map (contrib: {
        inherit (contrib) language;
        path = contrib.name;
      }) vscodeSnippetFiles;
    };
  };
  vscodeSnippetEntries =
    map (contrib: {
      inherit (contrib) name;
      path = contrib.source;
    }) vscodeSnippetFiles
    ++ (lib.singleton {
      name = "package.json";
      path = packageJsonFile;
    });
  vscodeSnippetsDrv = pkgs.linkFarm "vscode-snippets" vscodeSnippetEntries;

  # A submodule for a file with Lua snippets
  luaSnippet = submodule (
    { config, ... }:
    {
      options = {
        text = mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Lua snippets file contents.";
        };

        source = mkOption {
          type = with lib.types; nullOr path;
          description = "Path to a Lua snippets source file.";
        };
      };

      config = {
        source = mkIf (config.text != null) (pkgs.writeText "snippets.lua" config.text);
      };
    }
  );

  # Generate Lua snippets
  luaSnippetEntries = builtins.concatLists (
    lib.mapAttrsToList (
      ft: files:
      lib.imap1 (idx: file: {
        name = "${ft}/${toString idx}.lua";
        path = file.source;
      }) files
    ) cfg.lua
  );
  luaSnippetsDrv = pkgs.linkFarm "luasnip-lua-snippets" luaSnippetEntries;
in
{
  options.snippets = {
    enable = mkEnableOption "snippets";

    vscode = mkOption {
      type = listOf vscodeSnippets;
      default = [ ];
      description = "VS Code snippets";
    };

    lua = mkOption {
      type = attrsOf (listOf luaSnippet);
      default = { };
      description = ''
        Lua snippets.
      '';
    };

    build.vscode = mkOption {
      type = lib.types.package;
      description = "VS Code snippets derivation";
      readOnly = true;
      visible = false;
      internal = true;
    };

    build.lua = mkOption {
      type = lib.types.package;
      description = "Lua snippets derivation";
      readOnly = true;
      visible = false;
      internal = true;
    };
  };

  config = mkIf cfg.enable {
    snippets.build.vscode = vscodeSnippetsDrv;
    snippets.build.lua = luaSnippetsDrv;

    plugins.luasnip.fromVscode = mkIf (cfg.vscode != [ ]) [
      { paths = vscodeSnippetsDrv; }
    ];

    plugins.luasnip.fromLua = mkIf (cfg.lua != { }) [
      { paths = luaSnippetsDrv; }
    ];
  };
}
