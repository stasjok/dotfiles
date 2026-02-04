{ config, lib, ... }:
let
  cfg = config.ftplugin;
  inherit (lib) types mkOption mkIf mapAttrsToList optionalString;
  inherit (lib.nixvim) mkRaw toLuaObject;
in
{
  options.ftplugin = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        content = mkOption {
          type = types.lines;
          description = "Lua code to execute for this filetype";
        };
        undo = mkOption {
          type = types.str;
          default = "";
          description = "Undo commands to append to vim.b.undo_ftplugin";
        };
      };
    });
    default = {};
    description = "Filetype-specific configuration";
  };

  config = mkIf (cfg != {}) {
    autoCmd = mapAttrsToList (filetype: opts: {
      event = "FileType";
      pattern = filetype;
      callback = mkRaw ''
        function()
          -- Check if ftplugin was already executed (upstream or our own)
          if vim.b.did_ftplugin and vim.b.did_ftplugin >= 2 then
            return
          end
          vim.b.did_ftplugin = 2

          -- Execute user content
          ${opts.content}

          -- Append to undo_ftplugin
          ${optionalString (opts.undo != "") ''
            vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "") .. ${toLuaObject opts.undo}
          ''}
        end
      '';
    }) cfg;
  };
}
