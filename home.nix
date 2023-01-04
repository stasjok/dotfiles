{pkgs, ...}: let
  inherit (pkgs) nix;

  neovimWithPlugins = with pkgs; let
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

  pythonWithPackages = pkgs.python3.withPackages (ps:
    with ps; [
      requests
      pyyaml
      # ansible-language-server uses python to get sys.path in order to get collections list
      ansible
    ]);

  nix-profile = pkgs.buildEnv {
    name = "nix-profile-1";
    paths = with pkgs; [
      gnupg
      gnumake
      go-task
      neovimWithPlugins
      exa
      fd
      ripgrep
      fzf
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
      nixfmt
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
  };
in {
  # Imports
  imports = [
    ./programs
    ./fish
    ./tmux
  ];

  # Packages
  home.packages = [
    nix
    nix-profile
  ];

  # Home Manager
  programs.home-manager.enable = true;

  # Nix
  nix = {
    package = nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
    };
    registry = with builtins; {
      nixpkgs.to = (fromJSON (readFile ./flake.lock)).nodes.nixpkgs.locked;
      home-manager.to = (fromJSON (readFile ./flake.lock)).nodes.home-manager.locked;
      dotfiles.to = {
        type = "github";
        owner = "stasjok";
        repo = "dotfiles";
      };
    };
  };

  # Man
  programs.man = {
    enable = true;
    generateCaches = true;
  };

  # Files
  xdg.configFile = {
    nvim = {source = ./nvim;};
  };
}
