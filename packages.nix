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

in with stable; {
  inherit (stable)
    git
    gnupg
    tmux
    ;
  inherit (unstable)
    neovim-unwrapped
    ;
  packer-nvim = vimPlugins.packer-nvim.overrideAttrs (oldAttrs: {
    version = "2021-07-06";
    src = fetchFromGitHub {
      owner = "wbthomason";
      repo = "packer.nvim";
      rev = "3fdea07bec6cb733d2f82e50a10829528b0ed4a9";
      sha256 = "022klki8hgv1i5h91r1ag5jnk37iq6awgfijjzb47z2k525nh0nc";
    };
  });
}
