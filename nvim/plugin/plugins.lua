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
    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      commit = "ce0a3581e0fa6e3072bf06a97919d3e214ff00e6",
      config = function()
        require("plugin_configs.cmp").config()
      end,
      requires = {
        {
          "saadparwaiz1/cmp_luasnip",
          commit = "d6f837f4e8fe48eeae288e638691b91b97d1737f",
        },
        {
          "hrsh7th/cmp-nvim-lsp",
          commit = "accbe6d97548d8d3471c04d512d36fa61d0e4be8",
        },
        {
          "hrsh7th/cmp-path",
          commit = "4d58224e315426e5ac4c5b218ca86cab85f80c79",
        },
        {
          "hrsh7th/cmp-buffer",
          commit = "f83773e2f433a923997c5faad7ea689ec24d1785",
        },
        {
          "hrsh7th/cmp-cmdline",
          commit = "29ca81a6f0f288e6311b3377d9d9684d22eac2ec",
        },
      },
    },

    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      commit = "79662d8bb61bbee6af88bf559d9ed41c28eb5b88",
      config = function()
        require("plugin_configs.luasnip").config()
      end,
    },

    -- Comments toggle
    {
      "b3nj5m1n/kommentary",
      commit = "a5d7cd90059ad99b5e80a1d40d655756d86b5dad",
      keys = {
        { "n", "gc" },
        { "x", "gc" },
      },
    },

    -- Tree-sitter
    {
      "nvim-treesitter/nvim-treesitter",
      commit = "b995eebe84df88092a41cbfd591bfc1565f70d8e",
      config = function()
        require("plugin_configs.treesitter").config()
      end,
    },

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

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
      commit = "5eb87a0b05914d3763277ebe257bd5bafcdde8cd",
      config = function()
        require("plugin_configs.gitsigns").config()
      end,
    },

    -- Git visual interface
    {
      "TimUntersberger/neogit",
      commit = "0ff8e0c53092a9cb3a2bf138b05f7efd1f6d2481",
      cmd = "Neogit",
      keys = { { "n", "<Leader>g" } },
      wants = "diffview.nvim",
      config = function()
        require("plugin_configs.neogit").config()
      end,
    },

    -- Git diff viewer
    {
      "sindrets/diffview.nvim",
      commit = "a603c236bf6212d33011f5e81c89c504b4aec929",
      cmd = { "DiffviewOpen", "DiffviewFileHistory" },
      config = function()
        require("plugin_configs.diffview").config()
      end,
    },

    -- EditorConfig
    {
      "editorconfig/editorconfig-vim",
      commit = "3078cd10b28904e57d878c0d0dab42aa0a9fdc89",
      config = function()
        require("plugin_configs.editorconfig").config()
      end,
    },

    -- Tmux integration
    {
      "aserowy/tmux.nvim",
      commit = "71982a15c44d41795d17ce79d381032fdaf71a69",
      keys = require("plugin_configs.tmux").keys,
      config = function()
        require("plugin_configs.tmux").config()
      end,
    },

    -- Nix
    { "Freed-Wu/vim-nix", commit = "2fc254b90661f8190565b18874d0662bfcbec02c", ft = "nix" },

    -- Fish
    { "khaveesh/vim-fish-syntax", commit = "cf759d1ac42396ee2246a082eceb0debde04c445" },

    -- Jinja
    {
      "Glench/Vim-Jinja2-Syntax",
      commit = "2c17843b074b06a835f88587e1023ceff7e2c7d1",
      config = function()
        require("plugin_configs.jinja").config()
      end,
    },

    -- Ansible
    {
      "pearofducks/ansible-vim",
      commit = "469e55b101d85ff82687d975349b356b362194a6",
      config = function()
        require("plugin_configs.ansible").config()
      end,
    },

    -- SaltStack
    { "saltstack/salt-vim", commit = "6ca9e3500cc39dd417b411435d58a1b720b331cc" },

    -- MediaWiki
    {
      "chikamichi/mediawiki.vim",
      commit = "26e5737264354be41cb11d16d48132779795e168",
      config = function()
        require("plugin_configs.mediawiki").config()
      end,
    },
  },
})
