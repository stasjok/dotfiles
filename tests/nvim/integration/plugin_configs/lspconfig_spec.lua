describe("sumneko_lua", function()
  local sumneko_lua = require("plugin_configs.lspconfig.sumneko_lua")

  describe("root_dir()", function()
    it("stops at lua directory", function()
      assert.are.equal(
        vim.env.VIMRUNTIME,
        sumneko_lua.root_dir(vim.env.VIMRUNTIME .. "/lua/vim/shared.lua")
      )
    end)

    it("prioritizes stylua.toml over lua directory", function()
      local current_dir = vim.loop.fs_realpath(".")
      assert.is_not_nil(current_dir)
      assert.are.equal(
        current_dir,
        sumneko_lua.root_dir(vim.loop.fs_realpath("nvim/runtime/lua/utils.lua"))
      )
    end)
  end)

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
      assert.matches("types/stable$", new_config.settings.Lua.workspace.library[1])
      assert.are.equal(vim.env.VIMRUNTIME, new_config.settings.Lua.workspace.library[2])
      assert.are.equal(2, #new_config.settings.Lua.workspace.library)
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
      assert.matches("plenary.nvim", new_config.settings.Lua.workspace.library[1], 1, true)
      assert.are.equal("${3rd}/busted", new_config.settings.Lua.workspace.library[2])
      assert.are.equal("${3rd}/luassert", new_config.settings.Lua.workspace.library[3])
      assert.matches("lua/mini/test.lua", new_config.settings.Lua.workspace.library[4], 1, true)
      assert.matches("types/stable$", new_config.settings.Lua.workspace.library[5])
      assert.are.equal(vim.env.VIMRUNTIME, new_config.settings.Lua.workspace.library[6])
      assert.are.equal(6, #new_config.settings.Lua.workspace.library)
    end)
  end)
end)
