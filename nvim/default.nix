{
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  # Directory for plugin configurations managed by home-manager
  pluginConfigsDir = "plugin_configs";

  # Automatically read plugin config from ./${pluginConfigsDir}/PLUGIN_NAME.lua
  # and add all files from ./${pluginConfigsDir}/PLUGIN_NAME/ to runtime
  pluginDefaults = plugin: let
    normalizedName = replaceStrings ["."] ["-"] (getName plugin);
    configPath = "${pluginConfigsDir}/${normalizedName}.lua";
    runtimeDir = "${pluginConfigsDir}/${normalizedName}";
  in
    {type = "lua";}
    // optionalAttrs (pathExists ./${configPath}) {config = readFile ./${configPath};}
    // optionalAttrs (pathExists ./${runtimeDir}) {
      runtime = flip mapAttrs (readDir ./${runtimeDir}) (name: type: {
        source = ./${runtimeDir}/${name};
        recursive = true;
      });
    };

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
    plugin = pkgs.runCommandLocal "empty" {} "mkdir $out";
    optional = true;
  };
  # Empty plugin with config
  pluginConfig = config: emptyPlugin // {inherit config;};
  # Empty plugin with runtime
  pluginRuntime = runtime: emptyPlugin // {inherit runtime;};
in {
  programs.neovim = {
    enable = true;

    # Disable all providers
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

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
      sumneko-lua-language-server
      stylua
      # Nix
      nil
      alejandra
      nixpkgs-fmt
      nixfmt
      # Ansible
      ansible-language-server
      (ansible-lint.override {ansible-core = ansible_2_12;})
      # Json/YAML
      vscode-langservers-extracted
      yaml-language-server
      yamllint
      # Markdown
      marksman
      ltex-ls
      markdownlint-cli
      python3Packages.mdformat
      # Terraform
      terraform-ls
      # TypeScript
      typescript-language-server
      # Go
      gopls
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
          (pluginConfig (readFile ./init_before.lua))
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
        ])

        (mkAfter (mkPluginList [
          # init.lua after plugins
          (pluginConfig (readFile ./init_after.lua))
          # Other runtime files
          (pluginRuntime (pipe (readDir ./.) [
            (filterAttrs (name: type: type == "directory" && !(elem name [pluginConfigsDir])))
            (mapAttrs (name: type: {
              source = ./${name};
              recursive = true;
            }))
          ]))
        ]))
      ];

    # Lua libraries
    extraLuaPackages = p:
      with p; [
        jsregexp
      ];
  };
}
