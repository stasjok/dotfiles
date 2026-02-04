{ lib, ... }:
{
  options.programs.nixvim = lib.mkOption {
    type = lib.types.submoduleWith {
      modules = lib.toList {
        imports = [
          ./ftplugin.nix
          ./plugins
          ./runtime.nix
          ./snippets.nix
        ];
      };
    };
  };
}
