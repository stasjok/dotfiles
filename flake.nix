{
  description = "Nix flake for my dotfiles";

  inputs = {

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      # Released on 2022-04-16 04:53:52 via https://hydra.nixos.org/eval/1755745
      rev = "0b43a436fbbf96ecda249c4b8df5a349fe9f5e15";
      narHash = "sha256-3lmFtbxH3BSUYkq7gTtoW9dLqkIAkjXWhlncfdx0wCk=";
    };

  };

  outputs =
    { self
    , nixpkgs
    } @ args:

    let
      # Nixpkgs legacyPackages
      unstable = nixpkgs.legacyPackages.x86_64-linux;
      # Nixpkgs lib
      lib = unstable.lib;
      # Shortcuts
      inherit (unstable)
        fetchFromGitHub
        ;
    in
    {
      # Provide all upstream packages and lib
      legacyPackages.x86_64-linux = unstable;
      inherit lib;

      # Provide a package for nix profile with all my packages combined
      defaultPackage.x86_64-linux = unstable.buildEnv {
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
        buildInputs = [ unstable.man-db ];

        postBuild = ''
          mandb --no-straycats $out/share/man
          whatis --manpath=$out/share/man --wildcard '*' | sort > $out/share/man/whatis
          rm --dir $out/share/man/index.* $out/share/man/cat*
        '';
      };

      # My packages separately
      packages.x86_64-linux = rec {
        # Packages from current stable
        inherit (unstable)
          nix
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
          sumneko-lua-language-server
          stylua
          rnix-lsp
          terraform
          terraform-ls
          ;
        inherit (unstable.nodePackages)
          pyright
          bash-language-server
          node2nix
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
            nvimPlugins = vimPlugins // callPackage ./nix/nvim-plugins { inherit (vimUtils) buildVimPlugin; };
            configure.packages.nix.start = with nvimPlugins; [
              # Libraries
              plenary-nvim
              # Docs
              nvim-lua-guide
              luv-vimdocs
              # Color schemes
              onedark-nvim
              # File icons
              nvim-web-devicons
              # Text objects surrounding
              surround-nvim
              # Auto-pairs
              nvim-autopairs
              # Autocompletion
              nvim-cmp
              cmp-buffer
              cmp-cmdline
              cmp-nvim-lsp
              cmp_luasnip
              # Snippets
              luasnip
              # Comments toggle
              kommentary
              # Tree-sitter
              (nvim-treesitter.withPlugins treesitterAllGrammars)
              # LSP
              nvim-lspconfig
              null-ls-nvim
              lsp_signature-nvim
              lua-dev-nvim
              # Telescope
              telescope-nvim
              telescope-fzf-native-nvim
              # Git
              gitsigns-nvim
              neogit
              diffview-nvim
              # EditorConfig
              editorconfig-nvim
              # Tmux integration
              tmux-nvim
              # Languages
              vim-nix
              vim-fish-syntax
              vim-jinja2-syntax
              ansible-vim
              salt-vim
              mediawiki-vim
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
          with unstable.python3.pkgs; let
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

        # Reference input sources in order to avoid garbage collection
        sources =
          let
            inputs = removeAttrs args [ "self" ];
            nixpkgs-sources = lib.mapAttrsToList
              (name: value: { name = "share/nixpkgs/${name}"; path = value.outPath; })
              inputs;
          in
          unstable.linkFarm "nixpkgs-sources" nixpkgs-sources;
      } // import ./nix/node-packages/node-composition.nix { pkgs = unstable; };
    };
}

