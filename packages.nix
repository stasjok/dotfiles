let
  nixpkgs-stable = fetchTarball {
    name = "nixos-21.05.1268.21b696caf39";
    url = https://releases.nixos.org/nixos/21.05/nixos-21.05.1268.21b696caf39/nixexprs.tar.xz;
    sha256 = "1ffk57wfcfvvfjcxzialn9pgfmkanygz4h9kswv0jwiypjbrhzaa";
  };
  nixpkgs-unstable = fetchTarball {
    name = "nixpkgs-21.11pre300283.f930ea227ce";
    url = https://releases.nixos.org/nixpkgs/nixpkgs-21.11pre300283.f930ea227ce/nixexprs.tar.xz;
    sha256 = "1jw4s2psbx2ib1w69nymxj4jcyqgjg19n818ygc1rlspjscjfgyg";
  };

  stable = import nixpkgs-stable { config = {}; overlays = []; };
  unstable = import nixpkgs-unstable { config = {}; overlays = []; };

in with stable; [
  git
  gnupg
  tmux
  unstable.neovim
]
