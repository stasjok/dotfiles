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
        require("luasnip.extras.filetype_functions").extend_load_ft(${
          lib.nixvim.toLuaObject {
            jinja = [
              "ansible_filters"
              "ansible_jinja_stuff"
              "ansible_tests"
              "jinja_filters"
              "jinja_statements"
              "jinja_stuff"
              "jinja_tests"
              "salt_filters"
              "salt_jinja_stuff"
              "salt_statements"
              "salt_tests"
            ];
            salt = [
              "jinja_filters"
              "jinja_statements"
              "jinja_stuff"
              "jinja_tests"
              "salt_filters"
              "salt_jinja_stuff"
              "salt_statements"
              "salt_tests"
            ];
            ansible = [
              "ansible_filters"
              "ansible_jinja_stuff"
              "ansible_tests"
              "jinja_filters"
              "jinja_statements"
              "jinja_stuff"
              "jinja_tests"
            ];
            lua = [
              "lua"
              "lua_spec"
            ];
          }
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
    fromSnipmate = [
      {
        paths = [ "${config.build.extraFiles}/snippets" ];
      }
    ];

    # Clear LuaSnip FS watcher autocommands
    luaConfig.post = ''
      vim.api.nvim_del_augroup_by_name("_luasnip_fs_watcher")
    '';
  };

  # Mappings
  keymaps = [
    {
      mode = "i";
      key = "<C-H>";
      action = "<Plug>luasnip-expand-snippet";

    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-J>";
      action = "<Plug>luasnip-jump-next";
    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-K>";
      action = "<Plug>luasnip-jump-prev";
    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-L>";
      action = lib.nixvim.mkRaw ''
        function()
          if require("luasnip").choice_active() then
            require("luasnip").change_choice(1)
          end
        end
      '';
    }

    # On-the-fly snippets
    {
      mode = "i";
      key = "<C-E>";
      action = lib.nixvim.mkRaw ''
        function()
          local register = vim.fn.getcharstr()
          if #register == 1 and register:match('[%w"*+-]') then
            require("luasnip.extras.otf").on_the_fly(register)
          end
        end
      '';
    }
    {
      mode = "x";
      key = "<C-E>";
      action = lib.nixvim.mkRaw ''
        function()
          vim.api.nvim_feedkeys("c", "nx", false)
          require("luasnip.extras.otf").on_the_fly(vim.v.register)
        end
      '';
    }

    # These mappings switch to Insert mode when pressing <BS> or <Del>.
    {
      mode = "s";
      key = "<BS>";
      action = "<C-O>c";
    }
    {
      mode = "s";
      key = "<Del>";
      action = "<C-O>c";
    }
  ];
}
