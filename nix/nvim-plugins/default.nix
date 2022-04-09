{ buildVimPlugin }:

let
  generated = import ./generated.nix { inherit buildVimPlugin; };
in
generated // {
  onedark-nvim = generated.onedark-nvim.overrideAttrs (_: {
    prePatch = "rm Makefile";
  });
}
