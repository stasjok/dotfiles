{
  config,
  hmConfig,
  lib,
  ...
}:
{
  lsp.servers.emmylua_ls = {
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
          local is_std = vim.startswith(name, "${hmConfig.xdg.dataHome}/emmylua_ls/")
          if vim.startswith(name, "${builtins.storeDir}/") or is_std then
            local client = vim.lsp.get_clients({ name = "emmylua_ls" })[1]
            if client then
              local lib = vim.tbl_get(client, "settings", "Lua", "workspace", "library") or {}
              if vim.list_contains(lib, root_dir) or is_std then
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
}
