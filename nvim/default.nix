{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;
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

    imports = [
      ./autocmds.nix
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
      ./terminal
      ./treesitter
    ];
  };
}
