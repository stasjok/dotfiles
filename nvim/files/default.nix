{ lib, ... }:
{
  extraFiles =
    lib.pipe
      [
        ./lua/utils.lua
        ./lua/map.lua
      ]
      [
        (map (path: lib.removePrefix (toString ./. + "/") (toString path)))
        (lib.flip lib.genAttrs (path: {
          text = builtins.readFile ./${path};
        }))
      ];
}
