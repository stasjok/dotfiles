{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.luasnip = {
    enable = true;

    settings = {
      updateevents = [
        "TextChanged"
        "TextChangedI"
      ];
      region_check_events = "InsertEnter";
      cut_selection_keys = "<C-I>";

      ft_func = mkRaw ''
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

      load_ft_func = mkRaw ''
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

      # Imitate VSCode's behavior for nested placeholders
      # https://github.com/L3MON4D3/LuaSnip/wiki/Nice-Configs#imitate-vscodes-behaviour-for-nested-placeholders
      parser_nested_assembler = mkRaw ''
        function(_, snippetNode)
          local util = require("luasnip.util.util")
          local node_util = require("luasnip.nodes.util")

          local select = function(snip, no_move, dry_run)
            if dry_run then
              return
            end
            snip:focus()
            -- make sure the inner nodes will all shift to one side when the
            -- entire text is replaced.
            snip:subtree_set_rgrav(true)
            -- fix own extmark-gravities, subtree_set_rgrav affects them as well.
            snip.mark:set_rgravs(false, true)

            -- SELECT all text inside the snippet.
            if not no_move then
              require("luasnip.util.feedkeys").feedkeys_insert("<Esc>")
              node_util.select_node(snip)
            end
          end

          local original_extmarks_valid = snippetNode.extmarks_valid
          function snippetNode:extmarks_valid()
            -- the contents of this snippetNode are supposed to be deleted, and
            -- we don't want the snippet to be considered invalid because of
            -- that -> always return true.
            return true
          end

          function snippetNode:init_dry_run_active(dry_run)
            if dry_run and dry_run.active[self] == nil then
              dry_run.active[self] = self.active
            end
          end

          function snippetNode:is_active(dry_run)
            return (not dry_run and self.active) or (dry_run and dry_run.active[self])
          end

          function snippetNode:jump_into(dir, no_move, dry_run)
            self:init_dry_run_active(dry_run)
            if self:is_active(dry_run) then
              -- inside snippet, but not selected.
              if dir == 1 then
                self:input_leave(no_move, dry_run)
                return self.next:jump_into(dir, no_move, dry_run)
              else
                select(self, no_move, dry_run)
                return self
              end
            else
              -- jumping in from outside snippet.
              self:input_enter(no_move, dry_run)
              if dir == 1 then
                select(self, no_move, dry_run)
                return self
              else
                return self.inner_last:jump_into(dir, no_move, dry_run)
              end
            end
          end

          -- this is called only if the snippet is currently selected.
          function snippetNode:jump_from(dir, no_move, dry_run)
            if dir == 1 then
              if original_extmarks_valid(snippetNode) then
                return self.inner_first:jump_into(dir, no_move, dry_run)
              else
                return self.next:jump_into(dir, no_move, dry_run)
              end
            else
              self:input_leave(no_move, dry_run)
              return self.prev:jump_into(dir, no_move, dry_run)
            end
          end

          return snippetNode
        end
      '';

      snip_env = {
        "cr" = mkRaw "require('snippets.nodes').cr";
        "expand_conds" = mkRaw "require('snippets.expand_conditions')";
        "show_conds" = mkRaw "require('snippets.show_conditions')";
      };
    };

    # Filetypes
    filetypeExtend = {
      salt = [ "jinja" ];
    };

    # Clear LuaSnip FS watcher autocommands
    luaConfig.post = ''
      vim.api.nvim_del_augroup_by_name("_luasnip_fs_watcher")
    '';
  };

  # Mappings
  keymaps = [
    {
      mode = "i";
      key = "<C-Y>";
      action = "<Plug>luasnip-expand-snippet";
    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-L>";
      action = "<Plug>luasnip-jump-next";
    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-H>";
      action = "<Plug>luasnip-jump-prev";
    }
    {
      mode = [
        "i"
        "s"
        "n"
      ];
      key = "<C-J>";
      action = mkRaw ''
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
      action = mkRaw ''
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
      key = "<C-S>";
      action = mkRaw ''
        function()
          vim.api.nvim_feedkeys(string.format('"%sc', vim.v.register), "nx", false)
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
