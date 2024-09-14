{lib, ...}: {
  extraFiles =
    lib.pipe [
      ./terraform-vars.vim
    ] [
      (map (f: lib.nameValuePair ("indent/" + builtins.baseNameOf f) {source = f;}))
      builtins.listToAttrs
    ];
}
