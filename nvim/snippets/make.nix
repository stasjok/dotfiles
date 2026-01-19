{ lib, ... }:
{
  snippets.lua.make = lib.singleton {
    text = builtins.readFile ./make.lua;
  };
}
