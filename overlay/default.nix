{ inputs }:
final: prev:
let
  inherit (prev) lib;
  # Add flake inputs to autoArgs
  callPackage = lib.callPackageWith (final // { inherit inputs; });
in
{
  # Nvim
  neovim-patched = callPackage ../packages/neovim-patched { };

  # Fish plugins
  fishPlugins = prev.fishPlugins.overrideScope (callPackage ../packages/fish-plugins { });

  # Tmux plugins
  tmuxPlugins =
    prev.tmuxPlugins
    // (callPackage ../packages/tmux-plugins { inherit (final.tmuxPlugins) mkTmuxPlugin; });

  # Vim plugins
  vimPlugins = prev.vimPlugins.extend (callPackage ../packages/vim-plugins { });

  # Python packages
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (callPackage ../packages/python-packages { })
  ];

  # Lua interpreters and packages
  luaInterpreters = lib.fix (
    lib.extends (callPackage ../packages/lua-interpreters { }) (_: prev.luaInterpreters)
  );

  # Node packages
  nodePackages = prev.nodePackages.extend (callPackage ../packages/node-packages { });

  # Perl packages
  perlPackages = prev.perlPackages.overrideScope (callPackage ../packages/perl-packages { });

  # Tree-sitter grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-jinja2 = {
        src = inputs.tree-sitter-jinja2;
      };
    };
  };

  # Avoid binary clashing with nixfmt-rfc-style
  nixfmt-classic = prev.runCommand "nixfmt-classic" { } ''
    mkdir -p $out/bin
    ln -s ${lib.getBin prev.nixfmt-classic}/bin/nixfmt $out/bin/nixfmt-classic
  '';

  # beancount-language-server
  beancount-language-server = prev.beancount-language-server.overrideAttrs (prevAttrs: rec {
    version = "1.4.1";
    src = prevAttrs.src.override {
      rev = "v${version}";
      hash = "sha256-cx/Y0jBpnNN+QVEovpbhCG70VwOqwDE+8lBcRAJtlF4=";
    };
    cargoHash = "sha256-P3Oug9YNsTmsOz68rGUcYJwq9NsKErHt/fOCvqXixNU=";
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (prevAttrs) pname;
      inherit version src;
      hash = cargoHash;
    };
  });

  # https://github.com/fengkx/beancount-lsp
  beancount-lsp-server = callPackage ../packages/beancount-lsp-server { };

  # A tool to convert HomeBank files to Ledger format
  homebank2ledger = final.perlPackages.AppHomeBank2Ledger;

  # Allow changing kubernetes schema URL via settings
  yaml-language-server = prev.yaml-language-server.overrideAttrs {
    src = inputs.yaml-language-server;
  };

  # Disable history merging
  fzf = prev.fzf.overrideAttrs {
    patches = ./patches/fzf/0001-disable-fish-history-merge.patch;
  };

  # Last version of Ansible supporting python 2.6
  ansible_2_12 =
    let
      pkgs_22_11_pkgs =
        (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b")
        .legacyPackages.${final.system};
    in
    pkgs_22_11_pkgs.ansible_2_12.overrideAttrs (prevAttrs: {
      propagatedBuildInputs =
        prevAttrs.propagatedBuildInputs ++ (with pkgs_22_11_pkgs.python3Packages; [ jmespath ]);
    });

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = callPackage ../packages/packer { };
}
