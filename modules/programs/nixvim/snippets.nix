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
  strOrList = with lib.types; either str (listOf str);
  coercedStrToList = with lib.types; coercedTo str lib.singleton (listOf str);
  coercedPathToList = with lib.types; coercedTo path lib.singleton (listOf path);

  # A submodule for LSP snippet
  lspSnippet = submodule (
    { name, ... }:
    {
      freeformType = jsonFormat.type;
      options = {
        prefix = mkOption {
          description = "Snippet prefix";
          type = strOrList;
        };
        body = mkOption {
          description = "Snippet body";
          type = strOrList;
        };
        description = mkOption {
          description = "Snippet description";
          type = strOrList;
          default = name;
        };
      };
    }
  );

  # Submodule for a single filetype
  filetypeModule = submodule (
    { name, config, ... }:
    {
      options = {
        lsp = mkOption {
          type = attrsOf lspSnippet;
          default = { };
          description = "LSP snippets.";
          example = lib.literalExpression ''
            {
              example = {
                prefix = "example";
                body = "example $1";
                description = "Example snippet";
              };
            }'';
        };

        lua = mkOption {
          type = submodule {
            options = {
              text = mkOption {
                type = coercedStrToList;
                default = [ ];
                description = "Lua snippet file contents.";
                example = lib.literalExpression ''builtins.readFile ./snippets.lua'';
              };

              source = mkOption {
                type = coercedPathToList;
                default = [ ];
                description = "Paths to Lua snippet files.";
                example = lib.literalExpression ''./snippets.lua'';
              };
            };
          };
          default = { };
          description = "Lua snippets.";
        };

        build = {
          lsp = mkOption {
            type = with lib.types; nullOr path;
            default = null;
            visible = false;
            internal = true;
            description = "Generated LSP snippets JSON file for this filetype.";
          };

          lua = mkOption {
            type = with lib.types; nullOr path;
            default = null;
            visible = false;
            internal = true;
            description = "Generated directory containing Lua snippet files for this filetype.";
          };
        };
      };

      config.build = {
        lsp = mkIf (config.lsp != { }) (jsonFormat.generate "${name}.json" config.lsp);

        lua =
          let
            luaSources = map (pkgs.writeText "${name}.lua") config.lua.text ++ config.lua.source;
          in
          mkIf (luaSources != [ ]) (
            pkgs.linkFarm name (
              lib.imap (idx: path: {
                name = "${toString idx}.lua";
                inherit path;
              }) luaSources
            )
          );
      };

    }
  );

  # Generate LSP snippet files and package.json
  snippetFiles = lib.pipe cfg.filetype [
    (lib.mapAttrsToList (
      language: config: {
        inherit language;
        path = config.build.lsp;
      }
    ))
    (builtins.filter (attrs: attrs.path != null))
  ];
  snippetsDrv = pkgs.linkFarmFromDrvs "snippets" (
    builtins.catAttrs "path" snippetFiles
    ++ lib.singleton (
      jsonFormat.generate "package.json" {
        contributes.snippets = map (snippet: {
          inherit (snippet) language;
          path = lib.getName snippet.path;
        }) snippetFiles;
      }
    )
  );

  # Generate Lua snippets
  luaSnippetFiles = lib.pipe cfg.filetype [
    (lib.mapAttrsToList (_: config: config.build.lua))
    (builtins.filter (path: path != null))
  ];
  luaSnippetsDrv = pkgs.linkFarmFromDrvs "luasnip-lua-snippets" luaSnippetFiles;
in
{
  options.snippets = {
    enable = mkEnableOption "snippets";

    filetype = mkOption {
      type = attrsOf filetypeModule;
      default = { };
      description = "Snippets organized by filetype.";
      example = lib.literalExpression ''
        {
          nix = {
            lsp = {
              example = {
                prefix = "example";
                body = "example $1";
                description = "Example snippet";
              };
            };
            lua.text = builtins.readFile ./nix.lua;
          };
        }'';
    };

    build = {
      lsp = mkOption {
        type = lib.types.package;
        description = "LSP snippets derivation";
        readOnly = true;
        visible = false;
        internal = true;
      };

      lua = mkOption {
        type = lib.types.package;
        description = "Lua snippets derivation";
        readOnly = true;
        visible = false;
        internal = true;
      };
    };
  };

  config = mkIf cfg.enable {
    snippets.build = {
      lsp = snippetsDrv;
      lua = luaSnippetsDrv;
    };

    plugins.luasnip = {
      fromVscode = mkIf (snippetFiles != [ ]) [
        { paths = snippetsDrv; }
      ];

      fromLua = mkIf (luaSnippetFiles != [ ]) [
        { paths = luaSnippetsDrv; }
      ];
    };
  };
}
