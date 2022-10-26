local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local assert = require("luassert")

local T = new_set()

T["parent"] = new_set()

T["parent"]["runtimepath"] = function()
  eq(vim.fn.fnamemodify("nvim", ":p:h"), vim.opt.runtimepath:get()[1])
  assert.matches("vim%-pack%-dir$", vim.opt.runtimepath:get()[2])
  eq(vim.env.VIMRUNTIME, vim.opt.runtimepath:get()[3])
  eq(vim.fn.fnamemodify("nvim/after", ":p:h"), vim.opt.runtimepath:get()[4])
  eq(4, #vim.opt.runtimepath:get())

  local config_home = vim.fs.normalize("~/.config/nvim")
  local data_home = vim.fs.normalize("~/.local/state/nvim")
  for _, rtp in ipairs(vim.opt.runtimepath:get()) do
    expect.no_equality(config_home, rtp)
    expect.no_equality(data_home, rtp)
  end
end

T["parent"]["packpath"] = function()
  assert.matches("vim%-pack%-dir$", vim.opt.packpath:get()[1])
  eq(vim.env.VIMRUNTIME, vim.opt.packpath:get()[2])
  eq(2, #vim.opt.packpath:get())
end

T["parent"]["VIMRUNTIME"] = function()
  assert.matches(vim.fn.fnamemodify(vim.v.progpath, ":h:h"), vim.env.VIMRUNTIME, 1, true)
end

T["parent"]["scriptnames"] = function()
  local scriptnames = vim.api.nvim_cmd({ cmd = "scriptnames" }, { output = true })
  scriptnames = vim.split(scriptnames, "\n", { plain = true })
  eq(true, #scriptnames <= 8)
end

T["parent"]["ftdetect is disabled"] = function()
  eq("", vim.bo.filetype)
  assert.error_matches(function()
    vim.api.nvim_get_autocmds({ group = "filetypedetect" })
  end, "invalid augroup passed")
end

T["parent"]["syntax is disabled"] = function()
  eq("", vim.bo.syntax)
  eq(0, #vim.api.nvim_get_autocmds({ group = "syntaxset" }))
  assert.error_matches(function()
    vim.api.nvim_get_autocmds({ group = "Syntax" })
  end, "invalid augroup passed")
end

T["parent"]["plugins are disabled"] = function()
  eq(false, vim.go.loadplugins)
end

T["parent"]["updatecount is disabled"] = function()
  eq(0, vim.go.updatecount)
end

return T
