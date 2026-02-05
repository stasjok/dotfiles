{ myLib, ... }:
{
  extraConfigLua = myLib.readWrapDo ./terminal.lua;
}
