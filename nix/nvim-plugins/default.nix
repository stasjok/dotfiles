{ buildVimPlugin }:

let
  generated = import ./generated.nix { inherit buildVimPlugin; };
in
generated
