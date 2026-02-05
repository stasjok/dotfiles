{
  config.programs.nixvim.imports = [
    ./ftplugin.nix
    ./plugins
    ./runtime.nix
    ./snippets.nix
  ];
}
