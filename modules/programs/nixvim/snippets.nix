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
    source = contrib.source;
  }) cfg.vscode;
  packageJsonFile = jsonFormat.generate "package.json" {
    contributes = {
      snippets = map (contrib: { inherit (contrib) language path; }) vscodeSnippets;
    };
  };
  vscodeSnippetEntries = map (contrib: {
    name = contrib.path;
    path = contrib.source;
  }) vscodeSnippets;
  vscodeSnippetsDrv = pkgs.linkFarm "vscode-snippets" (
    [
      {
        name = "package.json";
        path = packageJsonFile;
      }
    ]
    ++ vscodeSnippetEntries
  );

  # A submodule for Lua snippets file
  luaSnippetFile = submodule (
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
  luaSnippetFiles = with lib.types; either luaSnippetFile (listOf luaSnippetFile);

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
      type = listOf (
        submodule (
          { config, ... }:
          {
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
              source = mkOption {
                type = with lib.types; nullOr path;
                description = "Path to a VSCode snippets JSON file.";
              };
            };

            config = {
              source = mkIf (config.snippets != { }) (jsonFormat.generate "snippets.json" config.snippets);
            };
          }
        )
      );
      default = [ ];
      description = "VSCode-style snippets";
    };

    lua = mkOption {
      type = attrsOf luaSnippetFiles;
      default = { };
      apply = builtins.mapAttrs (_: lib.toList);
      description = ''
        LuaSnip "Lua loader" snippets. Keys are filetypes, values are snippet-file specs
        (single or list). Files are generated as <ft>/*.lua.
      '';
    };

    build.vscode = mkOption {
      type = lib.types.package;
      description = "VSCode snippets derivation";
      readOnly = true;
      visible = false;
      internal = true;
    };

    build.lua = mkOption {
      type = lib.types.package;
      description = "LuaSnip Lua-loader snippets derivation";
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
