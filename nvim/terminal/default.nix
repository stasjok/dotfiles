{ lib, ... }:
{
  extraConfigLua = lib.nixvim.wrapDo (builtins.readFile ./terminal.lua);
}
