{
  config,
  lib,
  pkgs,
  helpers,
  hmConfig,
  ...
}: let
  cfg = config.runtime;
in {
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
    runtime = lib.mkMerge [
      # XDG_CONFIG_HOME
      {
        runtimePaths = lib.mkOrder 800 "${hmConfig.xdg.configHome}/nvim";
      }
      # Plugin pack and Nvim runtime
      (let
        paths = builtins.concatStringsSep "," [
          "${pkgs.vimUtils.packDir config.finalPackage.packpathDirs}"
          "${config.finalPackage.unwrapped}/share/nvim/runtime"
        ];
      in {
        runtimePaths = lib.mkOrder 1200 paths;
        packPaths = lib.mkOrder 1200 paths;
      })
      # XDG_CONFIG_HOME after directory
      {
        runtimePaths = lib.mkOrder 1700 "${hmConfig.xdg.configHome}/nvim/after";
      }
    ];

    extraConfigLuaPre = lib.mkIf cfg.enable (lib.mkBefore ''
      -- Runtime
      vim.o.runtimepath = ${helpers.toLuaObject cfg.runtimePaths}
      vim.o.packpath = ${helpers.toLuaObject cfg.packPaths}
    '');
  };
}
