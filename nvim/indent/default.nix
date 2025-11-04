{ lib, pkgs, ... }:
{
  extraFiles = {
    # Beancount indent from nathangrigg/vim-beancount plugin
    "indent/beancount.vim" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/nathangrigg/vim-beancount/589a4f06f3b2fd7cd2356c2ef1dafadf6b7a97cf/indent/beancount.vim";
        hash = "sha256-p0mFlHdW/mWC3ABObTVGG8mNM3pO7OT4k9OG9Z5eUEQ=";
      };
    };
  }
  //
    lib.pipe
      [
        ./salt.vim
        ./terraform-vars.vim
        ./yaml.vim
      ]
      [
        (map (f: lib.nameValuePair ("indent/" + builtins.baseNameOf f) { text = builtins.readFile f; }))
        builtins.listToAttrs
      ];
}
