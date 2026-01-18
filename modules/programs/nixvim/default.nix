{ lib, ... }:
{
  options.programs.nixvim = lib.mkOption {
    type = lib.types.submoduleWith {
      modules = lib.toList {
        imports = [
          ./plugins
          ./runtime.nix
          ./snippets.nix
        ];
      };
    };
  };
}
