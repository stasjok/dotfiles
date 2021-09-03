vim.api.nvim_command("packadd packer.nvim")

local packer = require("packer")
local join_paths = require("packer.util").join_paths

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
    { "nvim-lua/plenary.nvim", commit = "15c3cb9e6311dc1a875eacb9fc8df69ca48d7402" },
    { "tjdevries/lazy.nvim", commit = "238c1b9a661947b864a7d103f9d6b1f376c3b72f" },

    -- Color schemes
    {
      "ful1e5/onedark.nvim",
      commit = "5efacc13479cda116cac11e271d397c92fb07db5",
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
      commit = "0ec2d9baa1e721210e0ddfa7f7eb15dc4d5c530f",
      event = "InsertEnter",
      config = function()
        require("plugins.autopairs").config()
      end,
    },

    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      commit = "a8f62d2364d8bafa7d9c6247483a06aed88bdb73",
      event = "InsertEnter",
      wants = "nvim-autopairs",
      config = function()
        require("plugins.cmp").config()
      end,
      requires = {
        {
          "saadparwaiz1/cmp_luasnip",
          after = "nvim-cmp",
          commit = "438632c7996fe633e1b0f60c9089e8e8637f1bb7",
        },
        {
          "hrsh7th/cmp-nvim-lsp",
          commit = "9af212372c41e94d55603dea8ad9700f6c31573d",
        },
        {
          "hrsh7th/cmp-path",
          after = "nvim-cmp",
          commit = "48df45154ee644edf1b955d325be60928dd28d47",
        },
        {
          "hrsh7th/cmp-buffer",
          after = "nvim-cmp",
          commit = "a5774490b5ea8df8ce9e80ef4ec131cb4541702e",
        },
      },
    },

    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      commit = "4a06572252f2d68b51e0bd7e89da22abde1729b4",
      event = "InsertEnter",
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
      branch = "0.5-compat",
      commit = "27f5e99cdd1b4e7f6a5cc30016d990ebf81a561c",
      config = function()
        require("plugins.treesitter").config()
      end,
    },

    -- Language Servers configuration
    {
      "neovim/nvim-lspconfig",
      commit = "71c241425fd7a84f0ae33ea1eb7c071f20499bcd",
      config = function()
        require("plugins.lspconfig").config()
      end,
      requires = {
        -- General language server
        {
          "jose-elias-alvarez/null-ls.nvim",
          commit = "00b1cce2e089c01c3047ccdf60ce8709399791b9",
        },
      },
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      commit = "50e5e86ac37ee3989a0015d3934c5a961012990a",
      cmd = "Telescope",
      keys = require("plugins.telescope").keys,
      module = "telescope",
      config = function()
        require("plugins.telescope").config()
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

    { "folke/lua-dev.nvim", commit = "6a7abb62af1b6a4411a3f5ea5cf0cb6b47878cc0" },

    { "ray-x/lsp_signature.nvim", commit = "933ba2f059d965ee8db288f63869b8205ea223b8" },

    -- Git
    {
      "lewis6991/gitsigns.nvim",
      commit = "0d45fff0a28cebdc87604117c0fc46f3a64550f6",
      config = function()
        require("gitsigns").setup()
      end,
    },

    {
      "TimUntersberger/neogit",
      commit = "ee83d4fa8ac946e5e0064e65a5276e1ea030ae28",
      cmd = "Neogit",
      keys = "<leader>g",
      wants = "diffview.nvim",
      config = function()
        require("neogit").setup({
          disable_commit_confirmation = true,
          integrations = {
            diffview = true,
          },
        })
        vim.api.nvim_set_keymap("n", "<leader>g", "<Cmd>Neogit<CR>", { noremap = true })
      end,
    },

    {
      "sindrets/diffview.nvim",
      commit = "2411f5303192a9c8056ec174fb995773f90b52b8",
      cmd = "DiffviewOpen",
      config = function()
        require("diffview").setup({
          key_bindings = {
            view = {
              q = '<Cmd>lua require"diffview".close()<CR>',
            },
            file_panel = {
              q = '<Cmd>lua require"diffview".close()<CR>',
            },
          },
        })
      end,
    },

    -- Nix
    { "Freed-Wu/vim-nix", commit = "2fc254b90661f8190565b18874d0662bfcbec02c", ft = "nix" }, -- forked from LnL7/vim-nix

    -- Fish
    { "khaveesh/vim-fish-syntax", commit = "cf759d1ac42396ee2246a082eceb0debde04c445" },

    -- Jinja
    {
      "Glench/Vim-Jinja2-Syntax",
      commit = "2c17843b074b06a835f88587e1023ceff7e2c7d1",
      config = function()
        vim.g.jinja_syntax_html = 0
      end,
    },
    -- Ansible
    {
      "pearofducks/ansible-vim",
      commit = "804099202b72ffd4bf4ea4ce24d8d7bac8b9ae2d",
      config = function()
        vim.g.ansible_unindent_after_newline = 1
        vim.g.ansible_extra_keywords_highlight = 1
        vim.g.ansible_template_syntaxes = {
          ["*.sh.j2"] = "sh",
        }
      end,
    },
    -- SaltStack
    { "saltstack/salt-vim", commit = "6ca9e3500cc39dd417b411435d58a1b720b331cc" },
    -- MediaWiki
    {
      "chikamichi/mediawiki.vim",
      commit = "26e5737264354be41cb11d16d48132779795e168",
      config = function()
        vim.g.mediawiki_wikilang_to_vim_overrides = { sls = "sls" }
        vim.g.mediawiki_forced_wikilang = { "bash" }
      end,
    },
  },
})
