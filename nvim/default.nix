{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.neovim;

  # Packages
  neovim = pkgs.neovim-patched;

  lemminx = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "lemminx";
    version = "0.24.0";
    src = pkgs.fetchurl {
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

  # A hook to byte-compile all lua files in `$out`
  luaByteCompileHook =
    pkgs.makeSetupHook {
      name = "lua-byte-compile-hook";
      substitutions = {
        nvimBin = "${pkgs.neovim-unwrapped}/bin/nvim";
        luaByteCompileScript = ./lua-byte-compile.lua;
      };
    }
    ./lua-byte-compile-hook.sh;

  # Byte-compile a single lua file
  byteCompileLuaFile = file: let
    name =
      if builtins.isPath file
      then builtins.baseNameOf file
      else lib.getName file;
  in
    pkgs.runCommand name {
      nativeBuildInputs = [luaByteCompileHook];
    } ''
      cp ${file} $out
      chmod u+w $out
      runHook preFixup
    '';

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
  programs.neovim = {
    enable = true;

    # Disable all providers
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    # Set neovim as the default EDITOR
    defaultEditor = true;

    # Byte-compile lua files in runtime
    package = pkgs.symlinkJoin {
      name = "neovim-compiled-${neovim.version}";
      paths = [neovim];
      nativeBuildInputs = [luaByteCompileHook];
      postBuild = ''
        # Replace symlink with a file, or Nvim
        # will use wrong runtime directory
        rm $out/bin/nvim
        cp ${neovim}/bin/nvim $out/bin/nvim
        # Activate luaByteCompileHook manually
        runHook preFixup
      '';
      # Copy required attributes from original neovim package
      inherit (neovim) lua;
    };

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
    extraLuaConfig = lib.pipe ([./init.lua] ++ lib.filesystem.listFilesRecursive ./init.lua.d) [
      (builtins.filter (name: lib.hasSuffix ".lua" name))
      (builtins.map (file: luaBlock (baseNameOf file) file))
      concatNonEmptyStringsSep
    ];

    # Neovim plugins
    plugins = let
      # All plugins with its dependencies are placed in a start directory.
      # Python dependencies aren't supported.
      plugins = with pkgs.vimPlugins; let
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
        # Tree-sitter
        nvim-treesitter'
        playground
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
        null-ls-nvim
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
        vim-fish-syntax
        vim-jinja2-syntax
        ansible-vim
        salt-vim
        mediawiki-vim
      ];

      # Extend plugin list with dependencies
      allPlugins = let
        pluginWithDeps = plugin: [plugin] ++ builtins.concatMap pluginWithDeps plugin.dependencies or [];
      in
        lib.unique (builtins.concatMap pluginWithDeps plugins);

      # Byte-compile all plugins, remove help tags
      allPlugins' = lib.forEach allPlugins (plugin:
        plugin.overrideAttrs (prev: {
          nativeBuildInputs =
            lib.remove pkgs.vimUtils.vimGenDocHook prev.nativeBuildInputs or []
            ++ [luaByteCompileHook];
          configurePhase =
            concatNonEmptyStringsSep
            (builtins.filter (s: s != ":") [
              prev.configurePhase or ":"
              "rm -f doc/tags"
            ]);
        }));

      # Merge all plugins to one pack
      mergedPlugins = pkgs.vimUtils.toVimPlugin (pkgs.buildEnv {
        name = "plugin-pack";
        paths = allPlugins';
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
          # ftdetect
          "/ftdetect"
          # plenary.nvim
          "/data"
          # telescope-fzf-native-nvim
          "/build"
        ];
        # Activate vimGenDocHook manually
        postBuild = ''
          find $out -type d -empty -delete
          runHook preFixup
        '';
      });

      # Normalized plugin name
      pluginNormalizedName = name: builtins.replaceStrings ["."] ["-"] name;

      # Get plugin config
      pluginConfig = name: let
        configPath = ./plugins/${pluginNormalizedName name}/config.lua;
      in
        lib.optionalString (builtins.pathExists configPath) (luaBlock name configPath);

      # Make attributes for runtime attribute of a plugin
      mkRuntimeAttrs = dir:
        lib.pipe dir [
          lib.filesystem.listFilesRecursive
          (builtins.map (path: lib.removePrefix (builtins.toString dir + "/") (builtins.toString path)))
          (lib.flip lib.genAttrs (name: {
            source =
              if lib.hasSuffix ".lua" name
              then byteCompileLuaFile /${dir}/${name}
              else /${dir}/${name};
          }))
        ];

      # Get plugin runtime
      pluginRuntime = name: let
        runtimeDir = ./plugins/${pluginNormalizedName name}/runtime;
      in
        lib.optionalAttrs (builtins.pathExists runtimeDir) (mkRuntimeAttrs runtimeDir);

      # List of plugin names
      pluginNames = builtins.map lib.getName plugins;

      # Merge all plugin configs plus init.lua tail
      config =
        concatNonEmptyStringsSep (builtins.map pluginConfig pluginNames
          ++ [(luaBlock "init_after.lua" ./init_after.lua)]);

      # Merge all runtime files
      runtime = let
        pluginRuntimes = builtins.map pluginRuntime pluginNames;

        # List of plugin sources for lua-language-server
        luaLsLibrary = {
          "lua_ls_library.json" = {
            text = lib.pipe allPlugins [
              (builtins.filter (plugin: builtins.pathExists "${plugin}/lua"))
              # Append types and neovim runtime
              (lib.concat [neovim])
              (builtins.map (plugin: lib.nameValuePair (pluginNormalizedName (lib.getName plugin)) plugin))
              builtins.listToAttrs
              builtins.toJSON
            ];
          };
        };
      in
        builtins.foldl' (r1: r2: r1 // r2) (mkRuntimeAttrs ./runtime // luaLsLibrary) pluginRuntimes;
    in [
      {
        plugin = mergedPlugins;
        inherit config runtime;
        type = "lua";
      }
    ];

    # Lua libraries
    extraLuaPackages = p:
      with p; [
        jsregexp
      ];
  };

  # Byte-compile init.lua
  xdg.configFile."nvim/init.lua" = let
    initLua = pkgs.writeText "init.lua" ''
      ${cfg.extraLuaConfig}
      ${cfg.generatedConfigs.lua}'';
    initLuaCompiled = byteCompileLuaFile initLua;
  in
    lib.mkForce {
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
      src = inputs.vale-at-red-hat;
    in "${src}/.vale/styles/RedHat";
  };
}
