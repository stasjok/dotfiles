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

  # Tree-sitter grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-jinja2 = {
        src = final.fetchFromGitHub {
          owner = "theHamsta";
          repo = "tree-sitter-jinja2";
          rev = "3fa73cd4a871bf88e95d61adc8e66e7fb09016a1";
          hash = "sha256-LhyWfhtS1M+5m3wVnlHkM7e0yAG+Cfb1iBS1QuslG/c=";
        };
      };
    };
  };

  # Support incremental document changes
  typos-lsp = prev.typos-lsp.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.1.47";
      src = prevAttrs.src.override {
        tag = "v${finalAttrs.version}";
        hash = "sha256-Sv11I2HdPwgxA1SV1/bo9MS2aanzqjtm4KtnMl6iiqU=";
      };
      cargoHash = "sha256-qgpM5z5VF1fvaZKmJJZXTHOFMuz82a6UtnkKhgYUh3M=";
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = finalAttrs.cargoHash;
      };
    }
  );

  # Support param/@return completion
  emmylua-ls = prev.emmylua-ls.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.19.0";
      src = prevAttrs.src.override {
        hash = "sha256-bdvJInMuWJq7MZa+4wrKBn0myLTHCayhDAhB8Stjp6A=";
      };
      cargoHash = "sha256-bF6bdTbcHDecj+wVoNsaKBzsz96d3vo6cqp5MjSbT4E=";
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = finalAttrs.cargoHash;
      };
    }
  );

  # https://github.com/fengkx/beancount-lsp
  beancount-lsp-server = callPackage ../packages/beancount-lsp-server { };

  # A tool to convert HomeBank files to Ledger format
  homebank2ledger = final.perlPackages.AppHomeBank2Ledger;

  # Allow changing kubernetes schema URL via settings
  yaml-language-server = prev.yaml-language-server.overrideAttrs (prevAttrs: {
    src = prevAttrs.src.override {
      owner = "stasjok";
      tag = null;
      rev = "cc4e519833a9c4f91055f26d6b0ce532cb17227d";
      hash = "sha256-DXNxGHIlGabKH6xEivI/odVJU2DpMMbvqI1f3ReXW2Y=";
    };
  });

  # Support goto definition on path expressions
  nixd = prev.nixd.overrideAttrs (prevAttrs: rec {
    version = "2.8.2";
    src = prevAttrs.src.override {
      tag = version;
      hash = "sha256-rlV3ZAe7HKdt1SlPS6xy+vAxhddKhjn7XvoDnbq2AnE=";
    };
    patches = [
      # Completion improvements
      # https://github.com/nix-community/nixd/pull/698
      ./patches/nixd/0001-Increase-max-completion-items.patch
      ./patches/nixd/0002-Remove-completion-prefix-filtering.patch
    ];
    patchFlags = "-p2";
  });
  nixt = prev.nixt.overrideAttrs { inherit (final.nixd) version src; };
  nixf = prev.nixf.overrideAttrs (prevAttrs: {
    inherit (final.nixd) version src;
    buildInputs = prevAttrs.buildInputs ++ [ final.nixVersions.nixComponents_2_30.nix-expr ];
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

  # ansible-language-server was removed from nixpkgs
  ansible-language-server = callPackage ../packages/ansible-language-server { };

  # Freeze packer to the letest version with Mozilla Public License 2.0
  packer = callPackage ../packages/packer { };
}
