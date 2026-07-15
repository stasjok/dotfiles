{ lib, ... }: {
  # Can't use simple `config.programs.nixvim.imports` here, because
  # `programs.nixvim.type.getSubOptions []` doesn't return my options in than case,
  # and I need that for nixd completion
  options.programs.nixvim = lib.mkOption {
    type = lib.types.submoduleWith {
      modules = lib.toList {
        imports = [
          ./ftplugin.nix
          ./mylib.nix
          ./plugins
          ./runtime.nix
          ./snippets.nix
        ];
      };
    };
  };
}
