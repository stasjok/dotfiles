{
  description = "Nix flake for my dotfiles";

  inputs.nixpkgs.url = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import "${nixpkgs}/pkgs/top-level" {
      localSystem = "x86_64-linux";
      overlays = [self.overlays.default];
    };
  in {
    packages.x86_64-linux = with pkgs; rec {
      default = nix-profile;

      nix-profile = buildEnv {
        name = "nix-profile-${self.lastModifiedDate or "1"}";
        paths = [
          glibcLocales
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
          ansible_2_12
          (ansible-lint.override {ansible-core = ansible_2_12;})
          ansible-language-server
          yamllint
          shellcheck
          shfmt
          sumneko-lua-language-server
          stylua
          marksman
          python3Packages.mdformat
          ltex-ls
          nil
          nixpkgs-fmt
          alejandra
          terraform
          terraform-ls
          nodejs
          go
          gopls
          nodePackages.pyright
          nodePackages.bash-language-server
          nodePackages.vscode-langservers-extracted
          nodePackages.yaml-language-server
          nodePackages.markdownlint-cli
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.node2nix
        ];
        extraOutputsToInstall = ["man"];
        pathsToLink = [
          "/bin"
          "/lib/locale"
          "/share/man"
          "/share/fish/vendor_completions.d"
          "/share/fish/vendor_conf.d"
          "/share/fish/vendor_functions.d"
        ];
        buildInputs = [man-db];
        postBuild = ''
          mandb --no-straycats $out/share/man
          whatis --manpath=$out/share/man --wildcard '*' | sort > $out/share/man/whatis
          rm --dir $out/share/man/index.* $out/share/man/cat*
          mkdir -p $out/src
          ln -s ${nixpkgs} $out/src/nixpkgs
        '';
      };

      neovimWithPlugins = let
        nvim-treesitterWithPlugins = with vimPlugins;
          nvim-treesitter.withPlugins (p:
            nvim-treesitter.allGrammars
            ++ [
              p.tree-sitter-jinja2
            ]);
        plugins = with vimPlugins; [
          # Libraries
          plenary-nvim
          impatient-nvim
          mini-nvim
          # Interface
          kanagawa-nvim
          catppuccin-nvim
          nvim-web-devicons
          tmux-nvim
          # Tree-sitter
          nvim-treesitterWithPlugins
          playground
          # LSP
          nvim-lspconfig
          null-ls-nvim
          lsp_signature-nvim
          neodev-nvim
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
        luaPackages = p:
          with p; [
            jsregexp
          ];
        neovimConfig = neovimUtils.makeNeovimConfig {
          inherit plugins;
          extraLuaPackages = luaPackages;
          withPython3 = false;
          withRuby = false;
          wrapRc = false;
        };
        wrapperDisablePerlArgs = ["--add-flags" "--cmd 'let g:loaded_perl_provider=0'"];
        wrapperArgs = neovimConfig.wrapperArgs ++ wrapperDisablePerlArgs;
      in
        wrapNeovimUnstable neovim-unwrapped (neovimConfig // {inherit wrapperArgs;});

      pythonWithPackages = python3.withPackages (ps:
        with ps; [
          requests
          pyyaml
          # ansible-language-server uses python to get sys.path in order to get collections list
          ansible
        ]);
    };

    overlays.default = import ./nix/overlay;

    checks.x86_64-linux.default = pkgs.stdenv.mkDerivation {
      name = "nix-profile-test";
      src = ./.;
      buildInputs = [self.packages.x86_64-linux.default];
      phases = ["unpackPhase" "checkPhase" "installPhase"];
      checkPhase = ''
        export LANG=C.UTF-8;
        make test FROM_NIX=true
      '';
      doCheck = true;
      installPhase = "mkdir -p $out";
    };

    # Provide all upstream packages
    legacyPackages.x86_64-linux = pkgs;
  };
}
