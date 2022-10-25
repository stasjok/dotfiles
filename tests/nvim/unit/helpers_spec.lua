describe("helpers", function()
  local helpers = require("helpers")

  describe("set_rtp()", function()
    -- Backup values
    local rtp_orig = vim.opt.runtimepath:get()
    local packpath_orig = vim.opt.packpath:get()
    local home_orig = vim.env.HOME
    local xdg_home_orig = vim.env.XDG_CONFIG_HOME

    before_each(function()
      vim.opt.runtimepath = rtp_orig
      vim.opt.packpath = packpath_orig
    end)

    after_each(function()
      vim.opt.runtimepath = rtp_orig
      vim.opt.packpath = packpath_orig
      vim.env.HOME = home_orig
      vim.env.XDG_CONFIG_HOME = xdg_home_orig
    end)

    local home = "/home/test"
    local vimpack = "/nix/store/csk449qk4kxgkkgdv44z8j2yri30xphx-vim-pack-dir"
    local runtime = vim.env.VIMRUNTIME
    local rtp_nix = {
      vimpack,
      "/home/test/.config/nvim",
      runtime,
    }
    local rtp_default = {
      "/home/test/.config/nvim",
      runtime,
    }

    local tests = {
      ["works when XDG_CONFIG_HOME is not defined"] = {
        rtp = rtp_nix,
        expect_rtp = {
          home .. "/.config/nvim",
          vimpack,
          runtime,
          home .. "/.config/nvim/after",
        },
        expect_packpath = {
          vimpack,
          runtime,
        },
      },
      ["works when XDG_CONFIG_HOME is defined"] = {
        rtp = rtp_nix,
        xdg_home = "/rtp",
        expect_rtp = {
          "/rtp/nvim",
          vimpack,
          runtime,
          "/rtp/nvim/after",
        },
        expect_packpath = {
          vimpack,
          runtime,
        },
      },
      ["works when XDG_CONFIG_HOME is empty"] = {
        rtp = rtp_nix,
        xdg_home = "",
        expect_rtp = {
          home .. "/.config/nvim",
          vimpack,
          runtime,
          home .. "/.config/nvim/after",
        },
        expect_packpath = {
          vimpack,
          runtime,
        },
      },
      ["doesn't do anything if not running a nix version"] = {
        rtp = rtp_default,
        expect_rtp = rtp_default,
        expect_packpath = packpath_orig,
      },
    }

    for desc, opts in pairs(tests) do
      it(desc, function()
        vim.opt.rtp = opts.rtp
        vim.env.HOME = opts.home or home
        vim.env.XDG_CONFIG_HOME = opts.xdg_home
        helpers.set_rtp()
        assert.are.same(opts.expect_rtp, vim.opt.rtp:get())
        assert.are.same(opts.expect_packpath, vim.opt.packpath:get())
      end)
    end
  end)
end)
