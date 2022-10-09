local stub = require("luassert.stub")

describe("plugin/format", function()
  -- Stubs
  stub(vim.lsp.buf, "format")

  -- Load locals
  io.input("nvim/plugin/format.lua")
  local format_chunk = io.read("*a")
  format_chunk = format_chunk .. [[
return {
  format_with_client_id = format_with_client_id,
}]]
  local plugin = assert(loadstring(format_chunk, "Format plugin"))()

  describe("format_with_client_id", function()
    it("returns correct format function", function()
      local format_fun = plugin.format_with_client_id(10)
      format_fun()
      assert.stub(vim.lsp.buf.format).was_called_with({ id = 10 })
    end)
  end)
end)
