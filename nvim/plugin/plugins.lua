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
  {},
})
