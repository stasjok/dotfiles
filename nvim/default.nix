{
  lib,
  pkgs,
  ...
}: let
  # Library
  inherit (lib) filesystem flip forEach genAttrs getName optionalAttrs pipe removePrefix;
  inherit (builtins) pathExists readFile replaceStrings;
  inherit (lib) mkMerge mkBefore mkAfter;
  inherit (pkgs) emptyDirectory fetchurl stdenvNoCC;

  # Packages
  lemminx = stdenvNoCC.mkDerivation rec {
    pname = "lemminx";
    version = "0.24.0";
    src = fetchurl {
      url = "https://github.com/redhat-developer/vscode-xml/releases/download/${version}/lemminx-linux.zip";
      hash = "sha256-j0xWSICAXLbUwHc3ecJ57P41J0kpjq5GpEUMOXbr+Yw=";
    };
    nativeBuildInputs = with pkgs; [unzip];
    sourceRoot = ".";
    dontFixup = true;
    installPhase = ''
      install -D -T lemminx-linux -m 0755 $out/bin/${pname}
    '';
  };

  # Make attributes for runtime attribute of a plugin
  mkRuntimeAttrs = dir:
    pipe dir [
      filesystem.listFilesRecursive
      (map (path: removePrefix (toString dir + "/") (toString path)))
      (flip genAttrs (name: {source = /${dir}/${name};}))
    ];

  # Automatically read plugin config from ./plugins/<PLUGIN_NAME>/config.lua
  # and add all files from ./plugins/<PLUGIN_NAME>/runtime/ to runtime
  pluginDefaults = plugin: let
    normalizedName = replaceStrings ["."] ["-"] (getName plugin);
    configPath = ./plugins/${normalizedName}/config.lua;
    runtimeDir = ./plugins/${normalizedName}/runtime;
  in
    {type = "lua";}
    // optionalAttrs (pathExists configPath) {config = readFile configPath;}
    // optionalAttrs (pathExists runtimeDir) {runtime = mkRuntimeAttrs runtimeDir;};

  # Apply defaults to a list of plugins
  mkPluginList = plugins:
    forEach plugins (plugin: let
      pluginNormalized =
        if plugin ? plugin
        then plugin
        else {inherit plugin;};
    in
      pluginDefaults pluginNormalized.plugin // pluginNormalized);

  # Empty plugin
  emptyPlugin = {
    plugin = emptyDirectory;
    optional = true;
  };
  # Empty plugin with config
  pluginConfig = config: emptyPlugin // {config = readFile config;};
  # Empty plugin with runtime
  pluginRuntime = runtime: emptyPlugin // {runtime = mkRuntimeAttrs runtime;};
in {
  programs.neovim = {
    enable = true;

    # Disable all providers
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    # Set neovim as the default EDITOR
    defaultEditor = true;

    # Extra packages available to neovim
    extraPackages = with pkgs.nodePackages;
    with pkgs; [
      # Bash
      bash-language-server
      shellcheck
      shfmt
      # Python
      pyright
      black
      # Lua
      lua-language-server
      stylua
      # Nix
      nil
      alejandra
      nixpkgs-fmt
      nixfmt
      # Ansible
      ansible-language-server
      ansible-lint
      # Json/YAML/TOML
      vscode-langservers-extracted
      yaml-language-server
      yamllint
      taplo
      # Markdown
      marksman
      markdownlint-cli
      python3Packages.mdformat
      # Spelling
      ltex-ls
      vale
      # XML
      lemminx
      # Terraform
      terraform-ls
      # Packer
      packer
      # TypeScript
      typescript-language-server
      # Go
      gopls
      # Rust
      rust-analyzer
      rustc
      rustfmt
      # C
      clang-tools
    ];

    # Neovim plugins
    plugins = with pkgs.vimPlugins; let
      # nvim-treesitter with all tree-sitter parsers + extra parsers
      nvim-treesitterWithPlugins = nvim-treesitter.withPlugins (p:
        nvim-treesitter.allGrammars
        ++ (with p; [
          tree-sitter-jinja2
        ]));
    in
      mkMerge [
        (mkBefore (mkPluginList [
          # init.lua before plugins
          (pluginConfig ./init_before.lua)
          # impatient.nvim should be first
          impatient-nvim
          # Load colorscheme before other plugins
          catppuccin-nvim
        ]))

        (mkPluginList [
          # Libraries
          plenary-nvim
          mini-nvim
          # Interface
          nvim-web-devicons
          tmux-nvim
          # Tree-sitter
          nvim-treesitterWithPlugins
          playground
          # LSP
          nvim-lspconfig
          lsp_signature-nvim
          neodev-nvim
          null-ls-nvim
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
          # Languages
          vim-nix
          vim-fish-syntax
          vim-jinja2-syntax
          ansible-vim
          salt-vim
          mediawiki-vim
        ])

        (mkAfter (mkPluginList [
          # init.lua after plugins
          (pluginConfig ./init_after.lua)
          # Other runtime files
          (pluginRuntime ./runtime)
        ]))
      ];

    # Lua libraries
    extraLuaPackages = p:
      with p; [
        jsregexp
      ];
  };

  home.file = {
    # Vale configuration
    ".vale.ini".text = ''
      StylesPath = .vale
      MinAlertLevel = suggestion

      [*]
      BasedOnStyles = RedHat
    '';

    # Vale styles
    ".vale/RedHat".source = let
      src = fetchTree {
        type = "github";
        owner = "redhat-documentation";
        repo = "vale-at-red-hat";
        ref = "v267";
        narHash = "sha256-cjKgoozs6QPLtCvFit5rub9NeGwSrGYklUdE8jXQtLs=";
      };
    in "${src}/.vale/styles/RedHat";
  };
}
