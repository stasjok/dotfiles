local assert = require("luassert")

describe("test_nvim", function()
  describe("runtimepath", function()
    it("has current directory first", function()
      assert.equals(vim.fn.fnamemodify("nvim", ":p:h"), vim.opt.runtimepath:get()[1])
    end)

    it("has vim-pack-dir second", function()
      assert.matches("vim%-pack%-dir$", vim.opt.runtimepath:get()[2])
    end)

    it("has VIMRUNTIME third", function()
      assert.equals(vim.env.VIMRUNTIME, vim.opt.runtimepath:get()[3])
    end)

    it("has after directory last", function()
      assert.equals(vim.fn.fnamemodify("nvim/after", ":p:h"), vim.opt.runtimepath:get()[4])
      assert.equals(4, #vim.opt.runtimepath:get())
    end)

    it("doesn't contain home directory", function()
      local config_home = vim.fs.normalize("~/.config/nvim")
      local data_home = vim.fs.normalize("~/.local/state/nvim")
      for _, rtp in ipairs(vim.opt.runtimepath:get()) do
        assert.does_not.match(config_home, rtp)
        assert.does_not.match(data_home, rtp)
      end
    end)
  end)

  describe("packpath", function()
    it("has vim-pack-dir first", function()
      assert.matches("vim%-pack%-dir$", vim.opt.packpath:get()[1])
    end)

    it("has VIMRUNTIME last", function()
      assert.equals(vim.env.VIMRUNTIME, vim.opt.packpath:get()[2])
      assert.equals(2, #vim.opt.packpath:get())
    end)
  end)

  describe("VIMRUNTIME", function()
    it("matches nvim directory", function()
      assert.matches(vim.fn.fnamemodify(vim.v.progpath, ":h:h"), vim.env.VIMRUNTIME, 1, true)
    end)
  end)

  describe("scriptnames", function()
    it("minimal number of scripts are sourced", function()
      local scriptnames = vim.api.nvim_cmd({ cmd = "scriptnames" }, { output = true })
      scriptnames = vim.split(scriptnames, "\n", { plain = true })
      assert.is.near(4, #scriptnames, 4)
    end)
  end)

  describe("ftdetect", function()
    it("is disabled", function()
      assert.equals("", vim.bo.filetype)
      assert.error_matches(function()
        vim.api.nvim_get_autocmds({ group = "filetypedetect" })
      end, "invalid augroup passed")
    end)
  end)

  describe("syntax", function()
    it("is disabled", function()
      assert.equals("", vim.bo.syntax)
      assert.equals(0, #vim.api.nvim_get_autocmds({ group = "syntaxset" }))
      assert.error_matches(function()
        vim.api.nvim_get_autocmds({ group = "Syntax" })
      end, "invalid augroup passed")
    end)
  end)

  describe("plugins", function()
    it("are disabled", function()
      assert.equals(false, vim.go.loadplugins)
    end)
  end)

  describe("updatecount", function()
    it("is disabled", function()
      assert.equals(0, vim.go.updatecount)
    end)
  end)

  describe("shadafile", function()
    it("is disabled", function()
      assert.equals("NONE", vim.go.shadafile)
    end)
  end)

  describe("stdpath", function()
    it("config", function()
      assert.equals(vim.fn.fnamemodify("nvim", ":p:h"), vim.fn.stdpath("config"))
    end)

    it("data", function()
      -- Not sure why it's `nvim`
      assert.equals("nvim", vim.fn.stdpath("data"))
    end)

    it("state", function()
      assert.equals(vim.fn.fnamemodify("tests/nvim/state/nvim", ":p:h"), vim.fn.stdpath("state"))
    end)

    it("log", function()
      assert.equals(vim.fn.fnamemodify("tests/nvim/state/nvim", ":p:h"), vim.fn.stdpath("log"))
    end)

    it("cache", function()
      assert.equals(vim.fn.fnamemodify("tests/nvim/cache/nvim", ":p:h"), vim.fn.stdpath("cache"))
    end)

    it("config_dirs", function()
      assert.are.same({}, vim.fn.stdpath("config_dirs"))
    end)

    it("data_dirs", function()
      assert.are.same({}, vim.fn.stdpath("data_dirs"))
    end)
  end)
end)
