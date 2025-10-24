{ lib, ... }:
{
  imports = [
    ./beancount
    ./helm.nix
    ./mediawiki.nix
  ];

  extraFiles =
    lib.pipe
      [
        ./beancount.vim
        ./jinja.vim
        ./salt.vim
        ./helm.vim
        ./terraform-vars.vim
      ]
      [
        (map (f: lib.nameValuePair ("ftplugin/" + builtins.baseNameOf f) { source = f; }))
        builtins.listToAttrs
      ];
}
