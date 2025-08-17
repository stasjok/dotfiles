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

    beanquery = {
      enable = lib.mkEnableOption "beanquery" // {
        default = true;
        example = false;
      };
      package = lib.mkPackageOption pkgs "beanquery" { };
    };

    fava = {
      enable = lib.mkEnableOption "fava" // {
        default = true;
        example = false;
      };
      package = lib.mkPackageOption pkgs "fava" { };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [ cfg.package ]
      ++ lib.optional cfg.beanquery.enable cfg.beanquery.package
      ++ lib.optional cfg.fava.enable cfg.fava.package;
  };
}
