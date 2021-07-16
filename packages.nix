let
  nixpkgs-stable = fetchTarball {
    name = "nixos-21.05.1268.21b696caf39";
    url = https://releases.nixos.org/nixos/21.05/nixos-21.05.1268.21b696caf39/nixexprs.tar.xz;
    sha256 = "1ffk57wfcfvvfjcxzialn9pgfmkanygz4h9kswv0jwiypjbrhzaa";
  };
  nixpkgs-unstable = fetchTarball {
    name = "nixpkgs-21.11pre301805.dac74fead87";
    url = https://releases.nixos.org/nixpkgs/nixpkgs-21.11pre301805.dac74fead87/nixexprs.tar.xz;
    sha256 = "0435g5qwx2qwmsqf1ziazhi9xi0b6inax7j2daikgnsyc1jgcldc";
  };

  stable = import nixpkgs-stable { config = {}; overlays = []; };
  unstable = import nixpkgs-unstable { config = {}; overlays = []; };

in with stable; {
  inherit (stable)
    git
    gnupg
    tmux
    nodejs
    gcc
    ansible_2_9
    ;
  inherit (unstable)
    fish
    neovim-unwrapped
    tree-sitter
    ;
  packer-nvim = vimPlugins.packer-nvim.overrideAttrs (oldAttrs: {
    version = "2021-07-06";
    pname = "packer.nvim";
    src = fetchFromGitHub {
      owner = "wbthomason";
      repo = "packer.nvim";
      rev = "3fdea07bec6cb733d2f82e50a10829528b0ed4a9";
      sha256 = "022klki8hgv1i5h91r1ag5jnk37iq6awgfijjzb47z2k525nh0nc";
    };
  });
}
