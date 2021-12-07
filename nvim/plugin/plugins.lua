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
    -- Docs
    "nanotee/nvim-lua-guide",
    "nanotee/luv-vimdocs",

    -- Libraries
    { "nvim-lua/plenary.nvim", commit = "6bb0e09030a7c2af19bf288088ca815228de9429" },
    { "tjdevries/lazy.nvim", commit = "238c1b9a661947b864a7d103f9d6b1f376c3b72f" },

    -- Optimisations for loading Lua modules
    { "lewis6991/impatient.nvim", commit = "282b99b817d61e6c6860addf5629b641925a937a" },

    -- Color schemes
    {
      "ful1e5/onedark.nvim",
      commit = "af8e8fc727c9b3b5db09f433d129e659c57f2972",
      config = function()
        require("plugins.onedark").config()
      end,
    },

    -- File icons
    { "kyazdani42/nvim-web-devicons", commit = "da717e19678bd6ec33008cf92da05da1b8ceb87d" },

    -- Text objects surrounding
    {
      "blackCauldron7/surround.nvim",
      commit = "5c7fd08947968c296f37f1dad2ecbda52dd05792",
      keys = {
        { "n", "ys" },
        { "n", "cs" },
        { "n", "ds" },
        { "n", "cq" },
      },
      config = function()
        require("plugins.surround").config()
      end,
    },

    -- Auto-pairs
    {
      "windwp/nvim-autopairs",
      commit = "f858ab38b532715dbaf7b2773727f8622ba04322",
      config = function()
        require("plugins.autopairs").config()
      end,
    },

    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      commit = "d12ba90da372bfe5d9a103546ce1553341a2daff",
      config = function()
        require("plugins.cmp").config()
      end,
      requires = {
        {
          "saadparwaiz1/cmp_luasnip",
          commit = "75bf6434f175206cd219f9d2bbcae154a009346c",
        },
        {
          "hrsh7th/cmp-nvim-lsp",
          commit = "accbe6d97548d8d3471c04d512d36fa61d0e4be8",
        },
        {
          "hrsh7th/cmp-path",
          commit = "97661b00232a2fe145fe48e295875bc3299ed1f7",
        },
        {
          "hrsh7th/cmp-buffer",
          commit = "a706dc69c49110038fe570e5c9c33d6d4f67015b",
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
      commit = "052807223ba4d9babb412f12f08da0b34bc083cf",
      config = function()
        require("plugins.luasnip").config()
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
      commit = "1d66657e6d0f1f8f79ddc48ff1dac9788694cc2d",
      config = function()
        require("plugins.treesitter").config()
      end,
    },

    -- Configuration of language servers
    {
      "neovim/nvim-lspconfig",
      commit = "22b21bc000a8320675ea10f4f50f1bbd48d09ff2",
      config = function()
        require("plugins.lspconfig").config()
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

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      commit = "440c598de419858a056e7d9d42a0a6829cd5bb05",
      cmd = "Telescope",
      keys = require("plugins.telescope").keys,
      module = "telescope",
      config = function()
        require("plugins.telescope").config()
      end,
    },

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
      commit = "5eb87a0b05914d3763277ebe257bd5bafcdde8cd",
      config = function()
        require("plugins.gitsigns").config()
      end,
    },

    -- Git visual interface
    {
      "TimUntersberger/neogit",
      commit = "2a9ce6bbe682c31dbd5cd59214eb0ae93dab4ab6",
      cmd = "Neogit",
      keys = { { "n", "<Leader>g" } },
      wants = "diffview.nvim",
      config = function()
        require("plugins.neogit").config()
      end,
    },

    -- Git diff viewer
    {
      "sindrets/diffview.nvim",
      commit = "15ab6ab2fe88844238db1a175d18595fc2553c41",
      cmd = { "DiffviewOpen", "DiffviewFileHistory" },
      config = function()
        require("plugins.diffview").config()
      end,
    },

    -- EditorConfig
    {
      "editorconfig/editorconfig-vim",
      commit = "3078cd10b28904e57d878c0d0dab42aa0a9fdc89",
      config = function()
        require("plugins.editorconfig").config()
      end,
    },

    -- Tmux integration
    {
      "aserowy/tmux.nvim",
      commit = "e5eebe69577e40477996166f77a858c6708fc4fe",
      keys = require("plugins.tmux").keys,
      config = function()
        require("plugins.tmux").config()
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
        require("plugins.jinja").config()
      end,
    },

    -- Ansible
    {
      "pearofducks/ansible-vim",
      commit = "40e28ee318b968c09a1724cd25cd450330b136c9",
      config = function()
        require("plugins.ansible").config()
      end,
    },

    -- SaltStack
    { "saltstack/salt-vim", commit = "6ca9e3500cc39dd417b411435d58a1b720b331cc" },

    -- MediaWiki
    {
      "chikamichi/mediawiki.vim",
      commit = "26e5737264354be41cb11d16d48132779795e168",
      config = function()
        require("plugins.mediawiki").config()
      end,
    },
  },
})
