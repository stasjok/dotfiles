{
  description = "Nix flake for my dotfiles";

  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs }:

    let
      pkgs = import "${nixpkgs}/pkgs/top-level" {
        localSystem = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };
    in
    {
      packages.x86_64-linux = with pkgs; rec {

        default = nix-profile;

        nix-profile = buildEnv {
          name = "nix-profile-${self.lastModifiedDate or "1"}";
          paths = [
            nix
            fish
            tmux
            git
            gnupg
            gnumake
            go-task
            neovimWithPlugins
            exa
            bat
            fd
            ripgrep
            fzf
            delta
            pythonWithPackages
            black
            ansible
            ansible-lint
            yamllint
            shellcheck
            shfmt
            sumneko-lua-language-server
            stylua
            rnix-lsp
            terraform
            terraform-ls
            nodejs
            go
            gopls
            nodePackages.pyright
            nodePackages.bash-language-server
            nodePackages.vscode-langservers-extracted
            nodePackages."@ansible/ansible-language-server"
            nodePackages.yaml-language-server
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.node2nix
          ];
          extraOutputsToInstall = [ "man" ];
          pathsToLink = [
            "/bin"
            "/share/man"
            "/share/fish/vendor_completions.d"
            "/share/fish/vendor_conf.d"
            "/share/fish/vendor_functions.d"
          ];
          buildInputs = [ man-db ];
          postBuild = ''
            mandb --no-straycats $out/share/man
            whatis --manpath=$out/share/man --wildcard '*' | sort > $out/share/man/whatis
            rm --dir $out/share/man/index.* $out/share/man/cat*
            mkdir -p $out/src
            ln -s ${nixpkgs} $out/src/nixpkgs
          '';
        };

        neovimWithPlugins =
          let
            nvim-treesitterWithPlugins =
              vimPlugins.nvim-treesitter.withPlugins (p: with p; [
                tree-sitter-bash
                tree-sitter-c
                tree-sitter-cmake
                tree-sitter-comment
                tree-sitter-commonlisp
                tree-sitter-cpp
                tree-sitter-css
                tree-sitter-dockerfile
                tree-sitter-fennel
                tree-sitter-fish
                tree-sitter-go
                tree-sitter-gomod
                tree-sitter-hcl
                tree-sitter-html
                tree-sitter-java
                tree-sitter-javascript
                tree-sitter-jsdoc
                tree-sitter-json
                tree-sitter-json5
                tree-sitter-latex
                tree-sitter-lua
                tree-sitter-make
                tree-sitter-markdown
                tree-sitter-markdown-inline
                tree-sitter-nix
                tree-sitter-perl
                tree-sitter-php
                tree-sitter-python
                tree-sitter-query
                tree-sitter-regex
                tree-sitter-rst
                tree-sitter-ruby
                tree-sitter-rust
                tree-sitter-toml
                tree-sitter-tsx
                tree-sitter-typescript
                tree-sitter-vim
                tree-sitter-yaml
                tree-sitter-jinja2
              ]);
            configure.packages.nix.start = with vimPlugins; [
              # Libraries
              plenary-nvim
              impatient-nvim
              # Interface
              onedark-nvim
              nvim-web-devicons
              tmux-nvim
              # Tree-sitter
              nvim-treesitterWithPlugins
              playground
              # LSP
              nvim-lspconfig
              null-ls-nvim
              lsp_signature-nvim
              lua-dev-nvim
              # Autocompletion
              nvim-cmp
              cmp-buffer
              cmp-cmdline
              cmp-nvim-lsp
              cmp_luasnip
              # Snippets
              luasnip
              # Telescope
              telescope-nvim
              telescope-fzf-native-nvim
              # Editing
              surround-nvim
              nvim-autopairs
              kommentary
              # Git
              vim-fugitive
              gitsigns-nvim
              diffview-nvim
              # EditorConfig
              editorconfig-nvim
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
            nvimWrapperDisablePerlArgs = [ "--add-flags" "--cmd 'let g:loaded_perl_provider=0'" ];
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

        pythonWithPackages = python3.withPackages (ps: with ps; [
          requests
          pyyaml
          # ansible-language-server uses python to get sys.path in order to get collections list
          ansible
        ]);
      };

      overlays.default = import ./nix/overlay;

      # Provide all upstream packages
      legacyPackages.x86_64-linux = pkgs;
    };
}
