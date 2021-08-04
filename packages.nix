let
  nixpkgs-stable = fetchTarball {
    name = "nixos-21.05.2001.d4590d21006";
    url = https://releases.nixos.org/nixos/21.05/nixos-21.05.2001.d4590d21006/nixexprs.tar.xz;
    sha256 = "00p5vdk1ir4k35kc530rp9bjw3crvg0l1rmhsgyzhypavwvwy1lc";
  };
  nixpkgs-unstable = fetchTarball {
    name = "nixpkgs-21.11pre306170.4d3e13e51b6";
    url = https://releases.nixos.org/nixpkgs/nixpkgs-21.11pre306170.4d3e13e51b6/nixexprs.tar.xz;
    sha256 = "1jzlsza51vil0s64gl1djwd8nypi5x95x3yd89vw3iy25inhjl9h";
  };

  stable = import nixpkgs-stable { config = {}; overlays = []; };
  unstable = import nixpkgs-unstable { config = {}; overlays = []; };

in with stable; {
  inherit (stable)
    git
    gnupg
    tmux
    bat
    fd
    ripgrep
    fzf
    nodejs
    gcc
    ansible_2_9
    python3
    ;
  inherit (unstable)
    fish
    neovim-unwrapped
    tree-sitter
    stylua
    black
    ;
  inherit (unstable.nodePackages)
    pyright
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
  sumneko-lua-language-server = sumneko-lua-language-server.overrideAttrs (oldAttrs: rec {
    version = "2.3.3";
    src = fetchFromGitHub {
      owner = "sumneko";
      repo = "lua-language-server";
      rev = version;
      sha256 = "0q229i4aniqmj8rkdwyr1bpx9bjiwc06wcgizvsn98fyand1dnfr";
      fetchSubmodules = true;
    };
    ninjaFlags = [
      "-fcompile/ninja/linux.ninja"
    ];
  });
}
