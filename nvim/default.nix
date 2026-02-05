{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;

  # Read a lua chunk from file, wrap it in do...end block, and prefix it with `name` comment
  luaBlock =
    name: file:
    let
      indentedBlock = lib.pipe (lib.fileContents file) [
        (lib.splitString "\n")
        (lib.concatMapStringsSep "\n" (line: if line == "" then line else "  " + line))
      ];
    in
    ''
      -- ${name}
      do
      ${lib.removeSuffix "\n" indentedBlock}
      end
    '';

  concatNonEmptyStringsSep =
    strings:
    lib.pipe strings [
      (builtins.filter (str: str != ""))
      (builtins.concatStringsSep "\n")
    ];
in
{
  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-patched;
    nixpkgs.useGlobalPackages = true;

    # Make Nvim pure
    wrapRc = true;

    # Disable all providers
    withNodeJs = false;
    withRuby = false;

    # Set neovim as the default EDITOR
    defaultEditor = true;

    # Optimize runtimepath
    runtime.enable = true;

    # Performance optimizations
    performance = {
      # Byte compile everything
      byteCompileLua = {
        enable = true;
        plugins = true;
        nvimRuntime = true;
        luaLib = true;
      };

      # Reduce the number of runtime paths
      combinePlugins = {
        enable = true;
        # Make sure there are no standalone plugins except 'extraFiles'
        standalonePlugins = lib.mkForce [ (lib.getName cfg.build.extraFiles) ];
      };
    };

    # init.lua before plugins
    # Read `init.lua` file first, then read all .lua files in `init.lua.d` directory.
    extraConfigLuaPre = lib.pipe ([ ./init.lua ] ++ lib.filesystem.listFilesRecursive ./init.lua.d) [
      (builtins.filter (name: lib.hasSuffix ".lua" name))
      (builtins.map (file: luaBlock (baseNameOf file) file))
      concatNonEmptyStringsSep
    ];

    # init.lua after plugins
    extraConfigLuaPost = luaBlock "init_after.lua" ./init_after.lua;

    imports = [
      ./autopairs
      ./colorscheme.nix
      ./diagnostic.nix
      ./files
      ./filetypes
      ./format
      ./git
      ./icons.nix
      ./lsp
      ./mappings.nix
      ./options.nix
      ./patches.nix
      ./plugins
      ./skeletons.nix
      ./snippets
      ./treesitter
    ];
  };
}
