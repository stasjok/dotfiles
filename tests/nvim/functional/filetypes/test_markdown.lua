local helpers = dofile("tests/nvim/minitest_helpers.lua")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq, expect = MiniTest.expect.equality, helpers.expect

local child = new_child()

local T = new_set({
  hooks = {
    post_once = child.stop,
  },
})

T["test"] = new_set({
  hooks = {
    pre_once = function()
      child.setup()
      child.cmd("cd tests/nvim/functional/filetypes/markdown")
      child.cmd("edit test.md")
    end,
  },
})

T["test"]["marksman"] = function()
  if
    not child.lua_get(
      [[vim.wait(5000, function () return #vim.lsp.get_active_clients({name = "marksman"}) >= 1 end, 50)]]
    )
  then
    error("Marksman didn't start in time")
  end
  eq(
    vim.loop.fs_realpath("tests/nvim/functional/filetypes/markdown"),
    child.lua_get([[vim.lsp.get_active_clients({name = "marksman"})[1].config.root_dir]])
  )
  -- Test any request
  local symbols = child.lua_get([[
    vim.lsp.get_active_clients({ name = "marksman" })[1].request_sync("textDocument/documentSymbol", {
      textDocument = vim.lsp.util.make_text_document_params(),
    })
  ]])
  expect.no_equality(nil, symbols)
  eq(nil, symbols.err)
  expect.no_equality(0, #symbols.result)
end

T["test"]["markdownlint"] = function()
  local diagnostics = child.lua_get("vim.diagnostic.get(...)", { 0, { lnum = 0 } })
  eq(1, #diagnostics)
  eq("markdownlint", diagnostics[1].source)
  eq("MD009/no-trailing-spaces", diagnostics[1].code)
end

return T
