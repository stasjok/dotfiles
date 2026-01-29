{ lib, ... }:
{
  plugins.nvim-autopairs = {
    enable = true;

    settings = {
      enable_check_bracket_line = false;
      fast_wrap = lib.nixvim.emptyTable;
    };

    luaConfig.post = lib.nixvim.wrapDo (builtins.readFile ./pairs.lua);
  };
}
