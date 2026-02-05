{ myLib, ... }:
{
  extraFiles = myLib.mkExtraFiles ./. [
    ./lua/utils.lua
    ./lua/map.lua
  ];
}
