{
  config,
  lib,
  pkgs,
  ...
}: let
  # Library
  inherit (lib) filesystem flip forEach genAttrs getName optionalAttrs pipe removePrefix hasSuffix remove;
  inherit (builtins) pathExists readFile replaceStrings concatStringsSep filter attrValues foldl';
  inherit (lib) mkMerge mkAfter mkForce;
  inherit (pkgs) emptyDirectory fetchurl stdenvNoCC writeText runCommandLocal symlinkJoin;

  cfg = config.programs.neovim;

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
    name = getName plugin;
    normalizedName = replaceStrings ["."] ["-"] name;
    configPath = ./plugins/${normalizedName}/config.lua;
    runtimeDir = ./plugins/${normalizedName}/runtime;
  in
    {type = "lua";}
    // optionalAttrs (pathExists configPath) {config = "-- ${name}\n" + readFile configPath;}
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

  # Merge multiple plugins into one. Only for start plugins with lua configs.
  # Doesn't support dependencies.
  mergePlugins = name: plugins: let
    inherit (pkgs.vimUtils) vimGenDocHook toVimPlugin;

    plugins' = forEach plugins (plugin:
      plugin.overrideAttrs (prev: {
        # Remove help tags from individual plugins
        nativeBuildInputs = remove vimGenDocHook prev.nativeBuildInputs or [];
        configurePhase =
          concatStringsSep "\n"
          (filter (s: s != ":") [
            prev.configurePhase or ":"
            "rm -f doc/tags"
          ]);
      }));

    mergedPlugin = toVimPlugin (pkgs.buildEnv {
      inherit name;
      paths = plugins';
      pathsToLink = [
        # :h rtp
        "/autoload"
        "/colors"
        "/compiler"
        "/doc"
        "/ftplugin"
        "/indent"
        "/keymap"
        "/lang"
        "/lua"
        "/pack"
        "/parser"
        "/plugin"
        "/queries"
        "/rplugin"
        "/spell"
        "/syntax"
        "/tutor"
        "/after"
        # plenary.nvim
        "/data"
        # neodev.nvim
        "/types/stable"
        # telescope-fzf-native-nvim
        "/build"
      ];
      # Activate vimGenDocHook manually
      postBuild = ''
        . ${vimGenDocHook}/nix-support/setup-hook
        vimPluginGenTags
      '';
    });

    mergedPluginWithConfigs = foldl' (p1: p2: {
      plugin = mergedPlugin;
      config = concatStringsSep "\n" (filter (s: s != "") [p1.config or "" p2.config or ""]);
      runtime = p1.runtime or {} // p2.runtime or {};
      type = "lua";
    }) {} (mkPluginList plugins);
  in [mergedPluginWithConfigs];

  # Optional plugin
  optionalPlugin = plugin: {
    inherit plugin;
    optional = true;
  };
  # Empty plugin
  emptyPlugin = optionalPlugin emptyDirectory;
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

    # init.lua before plugins
    # Read `init.lua` file first, then read all .lua files in `init.lua.d` directory.
    extraLuaConfig = pipe ([./init.lua] ++ filesystem.listFilesRecursive ./init.lua.d) [
      (filter (name: hasSuffix ".lua" name))
      (map readFile)
      (concatStringsSep "\n")
    ];

    # Neovim plugins
    plugins = with pkgs.vimPlugins; let
      tree-sitter-parsers = symlinkJoin {
        name = "tree-sitter-parsers";
        paths =
          attrValues nvim-treesitter.grammarPlugins
          ++ (map pkgs.neovimUtils.grammarToPlugin (with pkgs.tree-sitter-grammars; [
            tree-sitter-jinja2
          ]));
      };
    in
      mkMerge [
        (mergePlugins "plugin-pack" [
          # Colorscheme
          catppuccin-nvim
          # Libraries
          plenary-nvim
          mini-nvim
          # Interface
          nvim-web-devicons
          smart-splits-nvim
          # Tree-sitter
          nvim-treesitter
          tree-sitter-parsers
          playground
          # LSP
          nvim-lspconfig
          lsp_signature-nvim
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

        (mkPluginList [
          (optionalPlugin neodev-nvim)
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

  # Byte-compile init.lua
  xdg.configFile."nvim/init.lua" = let
    initLua = writeText "init.lua" ''
      ${cfg.extraLuaConfig}
      ${cfg.generatedConfigs.lua}'';
    initLuaCompiled =
      runCommandLocal "init.luac" {
        nativeBuildInputs = [pkgs.neovim-unwrapped];
      } ''
        nvim -l ${writeText "lua-dump.lua" ''
          local chunk = assert(loadfile(_G.arg[1]))
          local out = assert(io.open(_G.arg[2], "wb"))
          if out:write(string.dump(chunk)) then
            out:close()
          else
            error("error writing to file")
          end
        ''} ${initLua} "$out"
      '';
  in
    mkForce {
      source = initLuaCompiled;
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
