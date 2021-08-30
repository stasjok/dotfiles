let
  nixpkgs-stable = fetchTarball {
    name = "nixos-21.05.2518.97c5d0cbe76";
    url = https://releases.nixos.org/nixos/21.05/nixos-21.05.2518.97c5d0cbe76/nixexprs.tar.xz;
    sha256 = "1bwv2x2mkmpmmipqmjn9cz3m3k4vkb2lv4a8dpm13bmir92v54xh";
  };
  nixpkgs-unstable = fetchTarball {
    name = "nixpkgs-21.11pre309670.253aecf69ed";
    url = https://releases.nixos.org/nixpkgs/nixpkgs-21.11pre309670.253aecf69ed/nixexprs.tar.xz;
    sha256 = "1ppnpjbdvxwnzjrmxx4z50sa2ymznbl83aq0zij6v0ix1xgfsdx4";
  };
  hurricanehrndz-nixcfg = fetchTarball {
    name = "hurricanehrndz-nixcfg-2021-08-02";
    url = https://github.com/hurricanehrndz/nixcfg/archive/993b3d67315563bfc4f9000e8e2e1d96c7d06ffe.tar.gz;
    sha256 = "1ifj4jdxwsc96xdyddca7ncixgb5yjyj8138azwhl8x62l78z6al";
  };

  stable = import nixpkgs-stable { config = {}; overlays = []; };
  unstable = import nixpkgs-unstable { config = {}; overlays = []; };
  nvim-ts-grammars = unstable.callPackage "${hurricanehrndz-nixcfg}/nix/pkgs/nvim-ts-grammars" { };
  my-node-packages = import ./nix/node-composition.nix { pkgs = stable; };

in with stable; {
  inherit (stable)
    git
    gnupg
    tmux
    exa
    bat
    fd
    ripgrep
    fzf
    delta
    ansible_2_9
    python3
    shellcheck
    shfmt
    ;
  inherit (nodePackages)
    bash-language-server
    node2nix
    ;
  inherit (unstable)
    fish
    neovim-unwrapped
    sumneko-lua-language-server
    stylua
    black
    ansible-lint
    yamllint
    ;
  inherit (unstable.nodePackages)
    pyright
    ;
  packer-nvim = unstable.vimPlugins.packer-nvim.overrideAttrs (oldAttrs: {
    # I need to change package name, because packer does :packadd packer.nvim
    pname = "packer.nvim";
    version = "2021-08-25";
    src = fetchFromGitHub {
      owner = "wbthomason";
      repo = "packer.nvim";
      rev = "09cc2d615bbc14bca957f941052e49e489d76537";
      sha256 = "1n7vhavf46vdpvpjk25i0w14w88lbm3nmlfac0rmikn6h5vma0kq";
    };
  });
  telescope-fzf-native-nvim = unstable.vimPlugins.telescope-fzf-native-nvim;
  nvim-treesitter-parsers = linkFarm "nvim-treesitter-parsers" (
    lib.attrsets.mapAttrsToList
      (name: drv:
        {
          name =
            "share/vim-plugins/nvim-treesitter-parsers/parser/"
            + (lib.strings.removePrefix "tree-sitter-"
                (lib.strings.removeSuffix "-grammar" name))
            + stdenv.hostPlatform.extensions.sharedLibrary;
          path = "${drv}/parser.so";
        }
      )
      (removeAttrs nvim-ts-grammars.builtGrammars [
        "tree-sitter-elixir" # doesn't install (error in derivation)
        "tree-sitter-gdscript" # ABI version mismatch
        "tree-sitter-ocamllex" # ABI version mismatch
        "tree-sitter-swift" # ABI version mismatch
      ])
  );
  # We need 2.10 version for ansible 2.9
  mitogen = unstable.python38Packages.mitogen.overrideAttrs (oldAttrs: rec {
    name = "python3.8-mitogen-${version}";
    version = "0.2.10rc1";
    src = fetchFromGitHub {
      owner = "mitogen-hq";
      repo = "mitogen";
      rev = "v${version}";
      sha256 = "0i600gy8qigkd693pd13vmm9knsvggpjpidyhr650xj75i6bbn7m";
    };
  });
} // my-node-packages
