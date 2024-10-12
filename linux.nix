{ pkgs, ... }:
{
  # Enable settings that make Home Manager work better
  # on GNU/Linux distributions other than NixOS
  targets.genericLinux.enable = true;

  # Build man package with support of the GNU gdbm database
  # (same as in most GNU/Linux distributions)
  programs.man.package = pkgs.man.override { db = pkgs.gdbm; };
}
