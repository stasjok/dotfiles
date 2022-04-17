{ vimUtils }:

let
  generated = import ./generated.nix { buildVimPlugin = vimUtils.buildVimPlugin; };
in
generated // {
  onedark-nvim = generated.onedark-nvim.overrideAttrs (_: {
    prePatch = "rm Makefile";
  });
}
