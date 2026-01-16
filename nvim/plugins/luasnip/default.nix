{ config, lib, ... }:
{
  plugins.luasnip = {
    enable = true;

    luaConfig.pre = builtins.readFile ./pre.lua;

    settings = {
      updateevents = "TextChanged,TextChangedI";
      region_check_events = "InsertEnter";
      store_selection_keys = "<C-H>";
      snip_env = {
        __snip_env_behaviour = "set";
      };
      ft_func = lib.nixvim.mkRaw "ft_func";
      load_ft_func = lib.nixvim.mkRaw ''
        extend_load_ft({
          jinja = {
            "jinja_statements",
            "jinja_stuff",
            "jinja_filters",
            "jinja_tests",
            "salt_statements",
            "salt_jinja_stuff",
            "salt_filters",
            "salt_tests",
            "ansible_jinja_stuff",
            "ansible_filters",
            "ansible_tests",
          },
          salt = {
            "jinja_statements",
            "jinja_stuff",
            "jinja_filters",
            "jinja_tests",
            "salt_statements",
            "salt_jinja_stuff",
            "salt_filters",
            "salt_tests",
          },
          ansible = {
            "jinja_statements",
            "jinja_stuff",
            "jinja_filters",
            "jinja_tests",
            "ansible_jinja_stuff",
            "ansible_filters",
            "ansible_tests",
          },
          lua = {
            "lua",
            "lua_spec",
          },
        })
      '';
      parser_nested_assembler = lib.nixvim.mkRaw ''
        function(pos, snip)
          local s = require("luasnip.nodes.snippet").S
          local i = require("luasnip.nodes.insertNode").I
          local c = require("luasnip.nodes.choiceNode").C
          snip.pos = nil
          -- Have to create temporary snippet, see: https://github.com/L3MON4D3/LuaSnip/issues/400
          local snip_text = s("", snip:copy()):get_static_text()
          return c(pos, { i(nil, snip_text), snip })
        end
      '';
    };

    # Snippet loaders
    fromLua = [
      {
        paths = [ "${config.build.extraFiles}/snippets" ];
      }
    ];
    fromVscode = [
      {
        paths = [ "${config.build.extraFiles}/snippets" ];
      }
    ];
    fromSnipmate = [
      {
        paths = [ "${config.build.extraFiles}/snippets" ];
      }
    ];

    luaConfig.post = builtins.readFile ./post.lua;
  };
}
