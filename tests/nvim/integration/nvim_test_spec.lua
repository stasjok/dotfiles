local assert = require("luassert")

describe("test_nvim", function()
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
    -- MiniTest doesn't have 'pending'
    local pending = pending or it
    pending("is disabled", function()
      assert.equals(0, vim.go.updatecount)
    end)
  end)

  describe("shadafile", function()
    -- MiniTest doesn't have 'pending'
    local pending = pending or it
    pending("is disabled", function()
      assert.equals("NONE", vim.go.shadafile)
    end)
  end)
end)
