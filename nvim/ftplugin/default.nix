{ lib, ... }:
{
  imports = [
    ./mediawiki.nix
  ];

  extraFiles =
    lib.pipe
      [
        ./jinja.vim
        ./salt.vim
        ./terraform-vars.vim
      ]
      [
        (map (f: lib.nameValuePair ("ftplugin/" + builtins.baseNameOf f) { source = f; }))
        builtins.listToAttrs
      ];
}
