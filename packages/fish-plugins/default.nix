{
  lib,
  pkgs,
}: final: prev: let
  callPackage = lib.callPackageWith (pkgs // {inherit (final) buildFishPlugin;});
in {
  foreign-env = callPackage ./foreign-env.nix {};
}
