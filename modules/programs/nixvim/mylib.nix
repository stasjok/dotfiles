{ lib, ... }:
{
  _module.args.myLib = {
    # Returns contents of the file wrapped in `do..end` block
    readWrapDo = file: lib.nixvim.wrapDo (builtins.readFile file);

    # Returns 'luaConfig' wrapped in 'do ... end'
    wrapDoLuaConfig =
      luaConfig:
      lib.mkMerge [
        {
          pre = lib.mkOrder 200 "do\n";
          post = lib.mkOrder 2000 "\nend\n";
        }
        (builtins.mapAttrs (_: v: if builtins.isPath v then builtins.readFile v else v) luaConfig)
      ];

    # Returns 'extraFiles' for all 'files' paths, stripped of 'parent' path
    mkExtraFiles =
      parent: files:
      lib.pipe files [
        (map (path: lib.removePrefix (toString parent + "/") (toString path)))
        (lib.flip lib.genAttrs (path: {
          text = builtins.readFile /${parent}/${path};
        }))
      ];
  };
}
