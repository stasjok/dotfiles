{ lib, ... }:
{
  extraConfigLua = lib.nixvim.wrapDo (builtins.readFile ./format.lua);

  imports = [
    ./none-ls.nix
  ];
}
