{ myLib, ... }:
{
  extraConfigLua = myLib.readWrapDo ./format.lua;

  imports = [
    ./none-ls.nix
  ];
}
