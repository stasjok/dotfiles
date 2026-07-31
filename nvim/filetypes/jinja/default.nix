{ myLib, ... }: {
  ftplugin.jinja.opts = {
    shiftwidth = 2;
    commentstring = "{#- %s #}";
  };

  extraConfigLuaPre = myLib.readWrapDo ./treesitter.lua;
}
