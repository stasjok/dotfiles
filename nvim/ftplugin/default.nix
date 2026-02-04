{ lib, ... }:
{
  imports = [
    ./beancount
    ./helm.nix
    ./mediawiki.nix
    ./nix.nix
  ];

  extraFiles =
    lib.pipe
      [
        ./beancount.vim
        ./go.lua
        ./gomod.lua
        ./helm.vim
        ./help.lua
        ./jinja.vim
        ./lua.lua
        ./markdown.lua
        ./salt.vim
        ./terraform-vars.vim
        ./xml.lua
      ]
      [
        (map (f: lib.nameValuePair ("ftplugin/" + builtins.baseNameOf f) { text = builtins.readFile f; }))
        builtins.listToAttrs
      ];
}
