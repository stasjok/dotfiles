{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.colorschemes.catppuccin;
in {
  options.colorschemes.catppuccin = {
    enableCompiled = lib.mkEnableOption "compiled catppuccin colorscheme";
  };

  config = lib.mkIf cfg.enableCompiled {
    extraPlugins = let
      # Nvim, which compiles catppuccin colorscheme to the colors directory
      neovim = pkgs.neovim.override {
        configure = {
          packages.catppuccin-nvim.start = [cfg.package];

          # Compile the colorscheme to the colors directory
          customRC = lib.nixvim.wrapLuaForVimscript ''
            require("catppuccin").setup(${
              lib.nixvim.toLuaObject (cfg.settings // {compile_path = "./colors";})
            })
          '';
        };
      };

      defaultFlavour =
        if cfg.settings.flavour != null && cfg.settings.flavour != "auto"
        then cfg.settings.flavour
        else "mocha";

      package = cfg.package.overrideAttrs rec {
        pname = "${lib.getName cfg.package}-compiled";
        name = "vimplugin-${pname}-${lib.getVersion cfg.package}";

        buildPhase = ''
          # Remove all colorschemes
          rm colors/*

          # Compile
          HOME=$(mktemp -d) ${lib.getExe neovim} --headless +q

          # Rename compiled colorschemes
          (
            cd colors
            rm cached
            for f in *; do
              mv $f catppuccin-$f.lua
            done
            cp catppuccin-${defaultFlavour}.lua catppuccin.lua
          )
        '';
      };
    in [package];

    colorscheme = lib.mkDefault "catppuccin";
  };
}
