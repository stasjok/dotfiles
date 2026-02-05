{
  config.programs.nixvim.imports = [
    ./ftplugin.nix
    ./mylib.nix
    ./plugins
    ./runtime.nix
    ./snippets.nix
  ];
}
