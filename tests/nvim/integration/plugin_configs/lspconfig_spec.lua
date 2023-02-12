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
end)
