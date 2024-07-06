{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nixvim;

  # Packages
  neovim = pkgs.neovim-patched;

  # Read a lua chunk from file, wrap it in do...end block, and prefix it with `name` comment
  luaBlock = name: file: let
    indentedBlock = lib.pipe (lib.fileContents file) [
      (lib.splitString "\n")
      (lib.concatMapStringsSep "\n" (line:
        if line == ""
        then line
        else "  " + line))
    ];
  in ''
    -- ${name}
    do
    ${lib.removeSuffix "\n" indentedBlock}
    end
  '';

  concatNonEmptyStringsSep = strings:
    lib.pipe strings [
      (builtins.filter (str: str != ""))
      (builtins.concatStringsSep "\n")
    ];
in {
  programs.nixvim = {
    enable = true;

    # Disable all providers
    withNodeJs = false;
    withRuby = false;

    # Set neovim as the default EDITOR
    defaultEditor = true;

    # Byte-compile lua files in runtime
    package = neovim;

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
      nixd
      nixfmt-rfc-style
      alejandra
      nixpkgs-fmt
      nixfmt-classic
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

    # init.lua before plugins
    # Read `init.lua` file first, then read all .lua files in `init.lua.d` directory.
    extraConfigLuaPre = lib.pipe ([./init.lua] ++ lib.filesystem.listFilesRecursive ./init.lua.d) [
      (builtins.filter (name: lib.hasSuffix ".lua" name))
      (builtins.map (file: luaBlock (baseNameOf file) file))
      concatNonEmptyStringsSep
    ];

    extraPlugins = with pkgs.vimPlugins; let
      # nvim-treesitter with tree-sitter parsers
      nvim-treesitter' = nvim-treesitter.withPlugins (parsers:
        nvim-treesitter.allGrammars
        ++ (with parsers; [
          tree-sitter-jinja2
        ]));

      # Byte-compile catppuccin colorscheme
      catppuccin-nvim = let
        neovim = pkgs.neovim.override {
          configure.packages.catppuccin-nvim.start = [pkgs.vimPlugins.catppuccin-nvim];
        };
      in
        pkgs.runCommand "catppuccin-nvim" {} ''
          ${neovim}/bin/nvim -l ${./catppuccin-nvim-config.lua}
          cd $out/colors
          rm cached
          for flavor in *; do
              mv "$flavor" "catppuccin-$flavor.lua"
          done
        '';
    in [
      # Colorscheme
      catppuccin-nvim
      # Libraries
      plenary-nvim
      mini-nvim
      # Interface
      nvim-web-devicons
      smart-splits-nvim
      fix-auto-scroll-nvim
      # Tree-sitter
      nvim-treesitter'
      # Autocompletion
      nvim-cmp
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp # Must be before nvim-lspconfig
      cmp_luasnip
      # Snippets
      luasnip
      # LSP
      nvim-lspconfig
      lsp_signature-nvim
      none-ls-nvim
      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      # Editing
      surround-nvim
      nvim-autopairs
      # Git
      vim-fugitive
      gitsigns-nvim
      diffview-nvim
      # Languages
      vim-nix
      vim-jinja2-syntax
      ansible-vim
      salt-vim
      mediawiki-vim
    ];

    extraConfigLua = let
      # List of plugins
      plugins = cfg.extraPlugins;

      # List of plugin names
      pluginNames = builtins.map lib.getName plugins;

      # Normalized plugin name
      pluginNormalizedName = name: builtins.replaceStrings ["."] ["-"] name;

      # Get plugin config
      pluginConfig = name: let
        configPath = ./plugins/${pluginNormalizedName name}/config.lua;
      in
        lib.optionalString (builtins.pathExists configPath) (luaBlock name configPath);

      # Merge all plugin configs
      config = concatNonEmptyStringsSep (builtins.map pluginConfig pluginNames);
    in
      config;

    extraConfigLuaPost = luaBlock "init_after.lua" ./init_after.lua;

    extraFiles = let
      # List of plugins
      plugins = cfg.extraPlugins;

      # Extend plugin list with dependencies
      allPlugins = let
        pluginWithDeps = plugin: [plugin] ++ builtins.concatMap pluginWithDeps plugin.dependencies or [];
      in
        lib.unique (builtins.concatMap pluginWithDeps plugins);

      # List of plugin names
      pluginNames = builtins.map lib.getName plugins;

      # Normalized plugin name
      pluginNormalizedName = name: builtins.replaceStrings ["."] ["-"] name;

      # Make attributes for runtime attribute of a plugin
      mkRuntimeAttrs = dir:
        lib.pipe dir [
          lib.filesystem.listFilesRecursive
          (builtins.map (path: lib.removePrefix (builtins.toString dir + "/") (builtins.toString path)))
          (lib.flip lib.genAttrs (name: builtins.readFile /${dir}/${name}))
        ];

      # Get plugin runtime
      pluginRuntime = name: let
        runtimeDir = ./plugins/${pluginNormalizedName name}/runtime;
      in
        lib.optionalAttrs (builtins.pathExists runtimeDir) (mkRuntimeAttrs runtimeDir);

      # Merge all runtime files
      runtime = let
        pluginRuntimes = builtins.map pluginRuntime pluginNames;

        # List of plugin sources for lua-language-server
        luaLsLibrary = {
          "lua_ls_library.json" = lib.pipe allPlugins [
            (builtins.filter (plugin: builtins.pathExists "${plugin}/lua"))
            # Append types and neovim runtime
            (lib.concat [neovim])
            (builtins.map (plugin: lib.nameValuePair (pluginNormalizedName (lib.getName plugin)) plugin))
            builtins.listToAttrs
            builtins.toJSON
          ];
        };
      in
        builtins.foldl' (r1: r2: r1 // r2) (mkRuntimeAttrs ./runtime // luaLsLibrary) pluginRuntimes;
    in
      runtime;

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
      src = inputs.vale-at-red-hat;
    in "${src}/.vale/styles/RedHat";
  };
}
