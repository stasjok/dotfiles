local stub = require("luassert.stub")

describe("sumneko_lua", function()
  -- We need to leave it functional because `require` depends on it
  local get_runtime_orig = vim.api.nvim__get_runtime
  local get_runtime = stub(vim.api, "nvim__get_runtime", function(...)
      return get_runtime_orig(...)
    end)
    ---@diagnostic disable-next-line: undefined-field
    .on_call_with({ "types/stable" }, true, { is_lua = true })
    .returns({ "/test/neodev.nvim/types/stable" })
    .on_call_with({ "lua/plenary" }, true, { is_lua = true })
    .returns({ "/test/plenary.nvim/lua/plenary" })
    .on_call_with({ "lua/mini/test.lua" }, true, { is_lua = true })
    .returns({ "/test/mini.nvim/lua/mini/test.lua" })

  local fs_realpath = stub(vim.loop, "fs_realpath", function(arg)
    return arg
  end)
  _G.package.loaded["plugin_configs.lspconfig.sumneko_lua"] = nil
  local sumneko_lua = require("plugin_configs.lspconfig.sumneko_lua")

  describe("on_new_config()", function()
    local new_config

    before_each(function()
      new_config = {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              path = { "?.lua", "?/init.lua" },
            },
            workspace = {
              library = {},
            },
          },
        },
      }
    end)

    it("works", function()
      sumneko_lua.on_new_config(new_config, "/tmp/test")
      assert.are.same({ "lua/?.lua", "lua/?/init.lua" }, new_config.settings.Lua.runtime.path)
      assert.are.same({
        "/test/neodev.nvim/types/stable",
        vim.env.VIMRUNTIME,
      }, new_config.settings.Lua.workspace.library)
    end)

    it("works for dotfiles", function()
      sumneko_lua.on_new_config(new_config, "/tmp/test/dotfiles")
      assert.are.same({
        "library/?.lua",
        "library/?/init.lua",
        "nvim/lua/?.lua",
        "nvim/lua/?/init.lua",
        "lua/?.lua",
        "lua/?/init.lua",
      }, new_config.settings.Lua.runtime.path)
      assert.are.same({
        "/test/plenary.nvim",
        "${3rd}/busted",
        "${3rd}/luassert",
        "/test/mini.nvim/lua/mini/test.lua",
        "/test/neodev.nvim/types/stable",
        vim.env.VIMRUNTIME,
      }, new_config.settings.Lua.workspace.library)
    end)
  end)

  get_runtime:revert()
  fs_realpath:revert()
end)
