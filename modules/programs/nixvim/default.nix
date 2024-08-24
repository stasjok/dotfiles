{lib, ...}: {
  options.programs.nixvim = lib.mkOption {
    type = lib.types.submodule {
      imports = [
        ./runtime.nix
        ./plugins
      ];
    };
  };
}
