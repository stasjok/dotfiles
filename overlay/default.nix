final: prev:
let
  inherit (prev) lib;
  inherit (final) callPackage;
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

  # https://github.com/fengkx/beancount-lsp
  beancount-lsp-server = callPackage ../packages/beancount-lsp-server { };

  # A tool to convert HomeBank files to Ledger format
  homebank2ledger = final.perlPackages.AppHomeBank2Ledger;

  # Support goto definition on path expressions
  nixd = prev.nixd.overrideAttrs (prevAttrs: {
    patches = [
      # Completion improvements
      # https://github.com/nix-community/nixd/pull/698
      ./patches/nixd/0001-Increase-max-completion-items.patch
      ./patches/nixd/0002-Remove-completion-prefix-filtering.patch
    ];
    patchFlags = "-p2";
  });

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
