{ lib, ... }:
{
  extraConfigLua = lib.nixvim.wrapDo (builtins.readFile ./format.lua);
}
