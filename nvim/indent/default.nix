{ lib, ... }:
{
  extraFiles =
    lib.pipe
      [
        ./salt.vim
        ./terraform-vars.vim
        ./yaml.vim
      ]
      [
        (map (f: lib.nameValuePair ("indent/" + builtins.baseNameOf f) { source = f; }))
        builtins.listToAttrs
      ];
}
