{ lib, ... }:
{
  _module.args.myLib = rec {
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

    # Returns 'extraFiles' for all 'files' paths, stripped of 'parent' path and prefixed with 'prefix'
    mkExtraFiles' =
      parent: prefix: files:
      lib.genAttrs' files (file: {
        name =
          prefix
          + lib.optionalString (prefix != "") "/"
          + lib.removePrefix (toString parent + "/") (toString file);
        value.text = builtins.readFile file;
      });

    # Returns 'extraFiles' for all 'files' paths, stripped of 'parent' path
    mkExtraFiles = parent: files: mkExtraFiles' parent "" files;
  };
}
