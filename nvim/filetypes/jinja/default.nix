{ config, ... }: {
  ftplugin.jinja.opts = {
    shiftwidth = 2;
    commentstring = "{#- %s #}";
  };

  extraConfigLuaPre = ''
    do
    ${builtins.replaceStrings
      [ "__JINJA_PARSER_PATH__" ]
      [ "${config.plugins.treesitter.package.builtGrammars.jinja}/parser" ]
      (builtins.readFile ./treesitter.lua)
    }
    end
  '';
}
