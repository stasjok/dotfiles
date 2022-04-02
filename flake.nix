{
  description = "Nix flake for my dotfiles";

  inputs = {

    nixos-21-05 = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      # Released on 2022-03-05 17:28:07 via https://hydra.nixos.org/eval/1744839
      rev = "530a53dcbc9437363471167a5e4762c5fcfa34a1";
      narHash = "sha256-y53N7TyIkXsjMpOG7RhvqJFGDacLs9HlyHeSTBioqYU=";
    };

    nixos-21-11 = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      # Released on 2022-03-24 05:31:45 via https://hydra.nixos.org/eval/1750680
      rev = "d2caa9377539e3b5ff1272ac3aa2d15f3081069f";
      narHash = "sha256-AG40Nt5OWz0LBs5p457emOuwLKOvTtcv/2fUdnEN3Ws=";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      # Released on 2022-03-27 03:47:33 via https://hydra.nixos.org/eval/1751103
      rev = "30d3d79b7d3607d56546dd2a6b49e156ba0ec634";
      narHash = "sha256-Ctij+dOi0ZZIfX5eMhgwugfvB+WZSrvVNAyAuANOsnQ=";
    };

  };

  outputs =
    { self
    , nixos-21-05
    , nixos-21-11
    , nixpkgs-unstable
    } @ args:

    let
      # Current stable nixpkgs
      current-version = nixos-21-11;
      # Nixpkgs legacyPackages
      stable-21-05 = nixos-21-05.legacyPackages.x86_64-linux;
      stable-21-11 = nixos-21-11.legacyPackages.x86_64-linux;
      unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      stable-current = current-version.legacyPackages.x86_64-linux;
      # Nixpkgs lib
      lib = current-version.lib;
      # Shortcuts
      inherit (stable-current)
        fetchFromGitHub
        ;
    in
    {
      # Provide all upstream packages and lib
      legacyPackages.x86_64-linux = stable-current;
      inherit lib;

      # Provide a package for nix profile with all my packages combined
      defaultPackage.x86_64-linux = stable-current.buildEnv {
        name = "nix-profile-${self.lastModifiedDate or "1"}";
        paths = builtins.attrValues self.packages.x86_64-linux;
        extraOutputsToInstall = [ "man" ];
        pathsToLink = [
          "/bin"
          "/share/man"
          "/share/nixpkgs"
          "/share/fish/vendor_completions.d"
          "/share/fish/vendor_conf.d"
          "/share/fish/vendor_functions.d"
        ];
        buildInputs = [ stable-current.man-db ];

        postBuild = ''
          mandb --no-straycats $out/share/man
          whatis --manpath=$out/share/man --wildcard '*' | sort > $out/share/man/whatis
          rm --dir $out/share/man/index.* $out/share/man/cat*
        '';
      };

      # My packages separately
      packages.x86_64-linux = rec {
        # Packages from current stable
        inherit (stable-current)
          fish
          tmux
          git
          gnupg
          exa
          bat
          fd
          ripgrep
          fzf
          delta
          python3
          black
          ansible-lint
          yamllint
          shellcheck
          shfmt
          stylua
          rnix-lsp
          terraform
          ;
        inherit (stable-current.nodePackages)
          bash-language-server
          node2nix
          ;
        # Packages from unstable
        inherit (unstable)
          nix
          sumneko-lua-language-server
          terraform-ls
          ;
        inherit (unstable.nodePackages)
          pyright
          ;

        # Overrided packages
        neovimWithPlugins =
          with unstable; let
            # Pin some of the tree-sitter grammars
            treesitterAllGrammars = p: builtins.attrValues (p // {
              tree-sitter-nix = p.tree-sitter-nix.overrideAttrs (_: {
                src = fetchFromGitHub {
                  owner = "cstrahan";
                  repo = "tree-sitter-nix";
                  rev = "6d6aaa50793b8265b6a8b6628577a0083d3b923d";
                  sha256 = "sha256-iYdP50IQ0Kg9kv/U5GsHy3wUTn2O34Oq3Vmre3EzczE=";
                };
              });
            });
            configure.packages.nix.start = with vimPlugins; [
              packer-nvim
              # Remove dependencies because they are managed by packer
              (telescope-fzf-native-nvim.overrideAttrs (_: { dependencies = [ ]; }))
              # TODO: build grammars using nvim-treesitter lock file
              (linkFarm "nvim-treesitter-parsers" [{
                name = "parser";
                path = tree-sitter.withPlugins treesitterAllGrammars;
              }])
            ];
            vimPackDir = vimUtils.packDir configure.packages;
            nvimDataDir = linkFarm "nvim-data-dir" [{ name = "nvim/site"; path = vimPackDir; }];
            nvimWrapperDataDirArgs = [ "--set" "XDG_DATA_DIRS" nvimDataDir ];
            nvimWrapperDisablePerlArgs = [
              "--add-flags"
              (lib.escapeShellArgs [ "--cmd" "let g:loaded_perl_provider=0" ])
            ];
            neovimConfig = neovimUtils.makeNeovimConfig {
              withPython3 = false;
              withRuby = false;
              inherit configure;
            };
            # Use vim-pack-dir as env, not as vimrc
            wrapNeovimArgs = neovimConfig // {
              wrapRc = false;
              wrapperArgs = neovimConfig.wrapperArgs ++ nvimWrapperDataDirArgs ++ nvimWrapperDisablePerlArgs;
            };
          in
          wrapNeovimUnstable neovim-unwrapped wrapNeovimArgs;

        ansibleWithMitogen =
          with stable-current.python3.pkgs; let
            # We need version 0.2 for ansible 2.9
            mitogen_0_2 = mitogen.overridePythonAttrs (oldAttrs: rec {
              version = "0.2.10";
              src = fetchFromGitHub {
                owner = "mitogen-hq";
                repo = "mitogen";
                rev = "v${version}";
                sha256 = "sha256-SFwMgK1IKLwJS8k8w/N0A/+zMmBj9EN6m/58W/e7F4Q=";
              };
            });
          in
          ansible.overridePythonAttrs (oldAttrs: {
            makeWrapperArgs = [
              "--suffix ANSIBLE_STRATEGY_PLUGINS : ${mitogen_0_2}/${python.sitePackages}/ansible_mitogen"
              "--set-default ANSIBLE_STRATEGY mitogen_linear"
            ];
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ mitogen_0_2 ];
          });

        cacert = stable-current.cacert.override {
          extraCertificateFiles = [ ./cacerts/absolutbank_root_2017.crt ];
        };

        # Reference input sources in order to avoid garbage collection
        sources =
          let
            inputs = removeAttrs args [ "self" ];
            nixpkgs-sources = lib.mapAttrsToList
              (name: value: { name = "share/nixpkgs/${name}"; path = value.outPath; })
              inputs;
          in
          stable-current.linkFarm "nixpkgs-sources" nixpkgs-sources;
      } // import ./node-packages/node-composition.nix { pkgs = stable-current; };
    };
}

