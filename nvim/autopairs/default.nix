{ lib, myLib, ... }:
{
  plugins.nvim-autopairs = {
    enable = true;

    settings = {
      enable_check_bracket_line = false;
      fast_wrap = lib.nixvim.emptyTable;
    };

    luaConfig.post = myLib.readWrapDo ./pairs.lua;
  };
}
