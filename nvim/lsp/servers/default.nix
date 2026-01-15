{
  config,
  lib,
  pkgs,
  ...
}:
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
    emmylua_ls = {
      enable = true;
      config = {
        root_dir = lib.nixvim.mkRaw ''
          function(buf, on_dir)
            local name = vim.api.nvim_buf_get_name(buf)
            local root_dir = vim.fs.root(name, {
              {
                ".emmyrc.json",
                ".luarc.json",
                ".stylua.toml",
                "stylua.toml",
              },
              {
                "lua",
                ".git",
              },
            })
            if vim.startswith(name, "${builtins.storeDir}/") then
              local client = vim.lsp.get_clients({ name = "emmylua_ls" })[1]
              if client then
                local lib = vim.tbl_get(client, "settings", "Lua", "workspace", "library") or {}
                if vim.list_contains(lib, root_dir) then
                  root_dir = client.root_dir or root_dir
                end
              end
            end
            on_dir(root_dir)
          end
        '';
        settings.Lua = {
          runtime = {
            version = "LuaJIT";
            requirePattern = [
              "lua/?.lua"
              "lua/?/init.lua"
            ];
          };
          workspace = {
            library = [
              "${config.package}/share/nvim/runtime"
            ];
          };
          strict = {
            requirePath = true;
            typeCall = true;
          };
        };
        cmd_env.VIMRUNTIME = "${config.package}/share/nvim/runtime";
        on_init = lib.nixvim.mkRaw ''
          function(client)
            local root_dir = client.root_dir
            if not root_dir then
              return
            end
            if
              vim
                .iter({
                  ".emmyrc.json",
                  ".luarc.json",
                })
                :any(function(file)
                  return vim.uv.fs_stat(vim.fs.joinpath(root_dir, file)) ~= nil
                end)
            then
              -- Clean config if there is a workspace config
              client.settings.Lua = nil
            elseif vim.fs.basename(root_dir) == "dotfiles" then
              client.settings.Lua.workspace.library = ${
                lib.nixvim.toLuaObject [
                  "${config.package}/share/nvim/runtime"
                  config.plugins.mini.package
                  config.plugins.luasnip.package
                ]
              }
              client.settings.Lua.workspace.workspaceRoots = {
                "nvim/runtime",
                "tests/nvim/runtime",
              }
            elseif vim.endswith(root_dir, "/share/nvim/runtime") then
              -- Nvim in Nix store
              client.settings.Lua.workspace.library = nil
            end
          end
        '';
      };
    };

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
