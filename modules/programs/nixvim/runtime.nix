{
  config,
  lib,
  pkgs,
  helpers,
  hmConfig,
  ...
}:
let
  cfg = config.runtime;
in
{
  options.runtime = {
    enable = lib.mkEnableOption "runtime management";

    runtimePaths = lib.mkOption {
      type = lib.types.commas;
      description = ''
        A comma separated list of runtime paths.
        Use `mkBefore` to define paths that should go first,
        `mkAfter` to define `/after` directories and
        `mkOrder 2000` to define last `/after` directories.
      '';
    };

    packPaths = lib.mkOption {
      type = lib.types.commas;
      description = "A comma separated list of package paths.";
    };
  };

  config = {
    runtime =
      let
        configHome =
          if config.wrapRc then "${config.build.extraFiles}" else "${hmConfig.xdg.configHome}/nvim";
      in
      lib.mkMerge [
        # User configuration
        {
          runtimePaths = lib.mkOrder 800 configHome;
        }
        # Plugin pack and Nvim runtime
        (
          let
            packDir = pkgs.neovimUtils.packDir (
              # Remove extraFiles plugin from packpathDirs
              if config.wrapRc then
                lib.updateManyAttrsByPath [
                  {
                    path = [
                      "myNeovimPackages"
                      "start"
                    ];
                    update = builtins.filter (p: p.name != config.build.extraFiles.name);
                  }
                ] config.build.nvimPackage.packpathDirs
              else
                config.build.nvimPackage.packpathDirs
            );
            paths = builtins.concatStringsSep "," [
              packDir
              "${config.build.nvimPackage.unwrapped}/share/nvim/runtime"
            ];
          in
          {
            runtimePaths = lib.mkOrder 1200 paths;
            packPaths = lib.mkOrder 1200 paths;
          }
        )
        # User configuration 'after' directory
        {
          runtimePaths = lib.mkOrder 1700 "${configHome}/after";
        }
      ];

    extraConfigLuaPre = lib.mkIf cfg.enable (
      lib.mkBefore ''
        -- Runtime
        vim.o.runtimepath = ${helpers.toLuaObject cfg.runtimePaths}
        vim.o.packpath = ${helpers.toLuaObject cfg.packPaths}
      ''
    );
  };
}
