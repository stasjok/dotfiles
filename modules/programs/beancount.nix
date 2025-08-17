{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.beancount;
in
{
  options.programs.beancount = {
    enable = lib.mkEnableOption "beancount";
    package = lib.mkPackageOption pkgs "beancount" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
