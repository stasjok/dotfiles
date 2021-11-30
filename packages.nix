let
  nixpkgs-stable = fetchTarball {
    # Released on 2021-11-29 21:50:19 from Git commit
    # https://github.com/NixOS/nixpkgs/commits/2553aee74fed8c2205a4aeb3ffd206ca14ede60f
    # via Hydra evaluation https://hydra.nixos.org/eval/1726412
    name = "nixos-21.05.4394.2553aee74fe";
    url = "https://releases.nixos.org/nixos/21.05/nixos-21.05.4394.2553aee74fe/nixexprs.tar.xz";
    sha256 = "1zp2wx9mqb7m3rixsd1pz6z11pfakny87m537nnlvl9axjf1mj1b";
  };
  nixpkgs-unstable = fetchTarball {
    # Released on 2021-11-29 20:21:59 from Git commit
    # https://github.com/NixOS/nixpkgs/commits/f366af7a1b3891d9370091ab03150d3a6ee138fa
    # via Hydra evaluation https://hydra.nixos.org/eval/1726352
    name = "nixpkgs-22.05pre334669.f366af7a1b3";
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-22.05pre334669.f366af7a1b3/nixexprs.tar.xz";
    sha256 = "1ikwfziw382fd3vbhljlf4hkiwjpg2c64dmfd6hcqqi9dzswq35y";
  };
  nixpkgs-unstable-for-vimplugins = fetchTarball {
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
  vimplugins = import nixpkgs-unstable-for-vimplugins { config = {}; overlays = []; };
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
  packer-nvim = vimplugins.vimPlugins.packer-nvim.overrideAttrs (oldAttrs: {
    # I need to change package name, because packer does :packadd packer.nvim
    pname = "packer.nvim";
    version = "2021-09-04";
    src = fetchFromGitHub {
      owner = "wbthomason";
      repo = "packer.nvim";
      rev = "daec6c759f95cd8528e5dd7c214b18b4cec2658c";
      sha256 = "1mavf0rwrlvwd9bmxj1nnyd32jqrzn4wpiman8wpakf5dcn1i8gb";
    };
  });
  telescope-fzf-native-nvim = vimplugins.vimPlugins.telescope-fzf-native-nvim;
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
