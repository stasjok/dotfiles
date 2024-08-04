-- Load minimal_init.lua
dofile("tests/nvim/minimal_init.lua")

-- Configure MiniTest
require("mini.test").setup({
  collect = {
    find_files = function()
      local tests = _G.arg[1] or "tests/nvim"

      if vim.endswith(tests, ".lua") then
        return { tests }
      else
        return vim.fn.globpath(tests, "**/*_test.lua", true, true)
      end
    end,
  },
})

-- Run tests
MiniTest.run()
