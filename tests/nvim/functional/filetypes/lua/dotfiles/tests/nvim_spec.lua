describe("test", function()
  it("test", function()
    -- Ensure there are diagnostics to wait for
    assert.is_nil(_NOT_EXISTENT)
    assert.are.same(1, 1)
  end)
end)
