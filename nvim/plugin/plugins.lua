local packer = require("packer")
local join_paths = require("packer.util").join_paths

--
-- Plugins managed by Nix
--

--
-- Plugins managed by Packer
--
packer.startup({

  -- Packer configuration
  config = {
    compile_path = join_paths(vim.fn.stdpath("data"), "site", "plugin", "packer_compiled.lua"),
    auto_reload_compiled = false,
    autoremove = true,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end,
    },
    profile = {
      enable = true,
    },
  },

  -- Plugin specifications
  {
    -- Configuration of language servers
    {
      "neovim/nvim-lspconfig",
      commit = "3d1baa811b351078e5711be1a1158e33b074be9e",
      config = function()
        require("plugin_configs.lspconfig").config()
      end,
      requires = {
        -- General language server
        {
          "jose-elias-alvarez/null-ls.nvim",
          commit = "214451829add4f050d9d94710a9112e6cdca3e03",
        },
        -- Sumneko lua language server configuration
        { "folke/lua-dev.nvim", commit = "1933c7e014e69484572b7fa1bf73bc51c42f10f4" },
        -- Signature help
        { "ray-x/lsp_signature.nvim", commit = "8f89ab239ef2569096b6805ea093a322985b8e4e" },
      },
    },
    {},
  },
})
