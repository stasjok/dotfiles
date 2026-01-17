{ config, lib, ... }:
{
  plugins.luasnip = {
    enable = true;

    settings = {
      updateevents = [
        "TextChanged"
        "TextChangedI"
      ];
      region_check_events = "InsertEnter";
      cut_selection_keys = "<C-H>";

      ft_func = lib.nixvim.mkRaw ''
        setmetatable({
          jinja = require("snippets.jinja_utils").jinja_ft_func("jinja"),
          salt = require("snippets.jinja_utils").jinja_ft_func("salt"),
          ansible = require("snippets.jinja_utils").jinja_ft_func("ansible"),
          lua = function()
            local buf_name = vim.api.nvim_buf_get_name(0)
            if buf_name:sub(-9, #buf_name) == "_spec.lua" then
              return { "lua", "lua_spec" }
            else
              return { "lua" }
            end
          end,
        }, {
          __call = function(tbl)
            local filetypes = {}
            for ft in vim.gsplit(vim.bo.filetype, ".", { plain = true }) do
              for _, filetype in ipairs(tbl[ft] and tbl[ft]() or { ft }) do
                table.insert(filetypes, filetype)
              end
            end
            return filetypes
          end,
          })
      '';

      load_ft_func = lib.nixvim.mkRaw ''
        require("luasnip.extras.filetype_functions").extend_load_ft({
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

      snip_env = {
        __snip_env_behaviour = "set";
      };
    };

    # Filetypes
    filetypeExtend = {
      salt = [ "jinja" ];
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
