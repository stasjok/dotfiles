{ lib, pkgs, ... }:
{
  plugins.lspconfig.enable = true;

  lsp.servers = {
    # Defaults
    "*".config.capabilities = {
      workspace.didChangeWatchedFiles.dynamicRegistration = true;
    };

    # Bash
    bashls.enable = true;

    # Python
    basedpyright.enable = true;
    ruff.enable = true;

    # Lua
    emmylua_ls.enable = true;

    # Nix
    nil_ls = {
      enable = true;
      config = {
        root_dir = lib.nixvim.mkRaw "vim.lsp.config.nixd.root_dir";
        on_init = lib.nixvim.mkRaw ''
          function(client)
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.hoverProvider = false
          end
        '';
        settings.nil.nix.flake.nixpkgsInputName = lib.nixvim.mkRaw "vim.NIL";
      };
    };
    nixd.enable = true;

    # Ansible
    ansiblels = {
      enable = true;
      package = pkgs.ansible-language-server;
      config = {
        settings.ansible = {
          completion.provideRedirectModules = false;
        };
      };
    };

    # Markdown
    marksman.enable = true;

    # Spelling
    ltex = {
      enable = true;
      activate = false;
      config.filetypes = [
        "markdown"
        "rst"
      ];
    };

    # JSON
    jsonls = {
      enable = true;
      config.settings.json = {
        # Need to specify explicitly.
        # See: https://github.com/b0o/SchemaStore.nvim/issues/8#issuecomment-1129531174
        validate.enable = true;
        format.enable = true;
        schemas = [
          {
            fileMatch = [
              "/snippets/*.json"
              "!package.json"
            ];
            url = "file://${pkgs.writeText "snippets.json" (builtins.readFile ../../schemas/snippets.json)}";
          }
        ];
      };
    };

    # YAML
    yamlls = {
      enable = true;
      config.settings.yaml = {
        customTags = [ "!vault" ];
        kubernetesSchemaUrl = lib.nixvim.mkRaw ''
          (function()
            local schema_path = vim.fs.normalize("~/.kube/json-schema/all.json")
            return vim.fn.filereadable(schema_path) == 1 and schema_path or nil
          end)()
        '';
        schemas = {
          kubernetes = [
            "/deckhouse/**/*.yml"
            "/deckhouse/**/*.yaml"
            "/kubernetes/**/*.yml"
            "/kubernetes/**/*.yaml"
          ];
        };
      };
    };

    # TOML
    taplo = {
      enable = true;
      config.settings.formatter.arrayAutoCollapse = false;
    };

    # Terraform
    terraformls.enable = true;

    # XML
    lemminx.enable = true;

    # TypeScript
    vtsls.enable = true;

    # Go
    gopls = {
      enable = true;
      config.settings.gopls = {
        staticcheck = true;
        semanticTokens = true;
        semanticTokenTypes = {
          string = false;
          number = false;
        };
      };
    };

    # Rust
    rust_analyzer = {
      enable = true;
    };

    # Typos
    typos_lsp.enable = true;

    # Helm language server
    helm_ls.enable = true;

    # Perl
    perlnavigator.enable = true;

    # C
    clangd.enable = true;

    # beancount-lsp-server
    beancount-lsp-server = {
      enable = true;
      name = "beancount-lsp-server";
      package = pkgs.beancount-lsp-server;
      config = {
        cmd = [
          "beancount-lsp-server"
          "--stdio"
        ];
        cmd_env = {
          NODE_OPTIONS = "--max-old-space-size=6144";
        };
        filetypes = [ "beancount" ];
        root_markers = [
          "ledger.beancount"
          ".git"
        ];
        init_options.exclude = [
          "zenmoney/**"
          "easyfinance/**"
        ];
        settings = {
          beanLsp = {
            mainBeanFile = "ledger.beancount";
          };
        };
      };
    };
  };

  extraPackages = with pkgs; [
    # bashls
    shfmt
    # Nix
    nixfmt
    # rust_analyzer
    rustc
    rustfmt
    # ansiblels
    ansible-lint
    yamllint
  ];

  extraFiles = {
    "lsp/lua_ls.lua".text = builtins.readFile ./lua_ls.lua;
    "lsp/nixd.lua".text = builtins.readFile ./nixd.lua;
  };
}
