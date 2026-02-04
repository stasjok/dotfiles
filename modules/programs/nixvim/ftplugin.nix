{ config, lib, ... }:
let
  cfg = config.ftplugin;

  inherit (lib) types mkOption mkIf;
  inherit (lib.nixvim) mkRaw toLuaObject lua-types;
in
{
  options.ftplugin = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          options = {
            content = mkOption {
              type = types.lines;
              description = "Lua code to execute for this filetype";
            };
            undo = mkOption {
              type = types.separatedString " | ";
              default = "";
              description = "Undo commands to append to vim.b.undo_ftplugin";
            };
            opts = mkOption {
              type = types.attrsOf lua-types.anything;
              default = { };
              description = "Nvim options to set for this filetype";
            };
          };

          config = mkIf (config.opts != { }) {
            content = ''
              local set_option_value = vim.api.nvim_set_option_value
              ${builtins.concatStringsSep "\n" (
                lib.mapAttrsToList (
                  name: value:
                  "set_option_value(${toLuaObject name}, ${toLuaObject value}, ${toLuaObject { scope = "local"; }})"
                ) config.opts
              )}
            '';
            undo = "setlocal " + lib.concatMapAttrsStringSep " " (name: _: "${name}<") config.opts;
          };
        }
      )
    );
    default = { };
    description = "Filetype-specific configuration";
  };

  config = mkIf (cfg != { }) {
    autoCmd = lib.mapAttrsToList (filetype: opts: {
      event = "FileType";
      pattern = filetype;
      desc = "${filetype} filetype configuration";
      callback = mkRaw ''
        function()
          if vim.b.did_ftplugin and vim.b.did_ftplugin >= 2 then
            return
          end
          vim.b.did_ftplugin = 2

          ${opts.content}

          ${lib.optionalString (opts.undo != "") ''
            vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "") .. ${toLuaObject opts.undo}
          ''}
        end
      '';
    }) cfg;
  };
}
