local stub = require("luassert.stub")
local spy = require("luassert.spy")
local match = require("luassert.match")

describe("test.utils", function()
  local helpers = dofile("tests/nvim/helpers.lua")

  describe("stubs()", function()
    -- Stub `after_each` for this block
    local after_each_orig = after_each
    after_each = stub.new()
    after_each_orig(function()
      after_each:clear()
    end)

    local funcs = {
      a = function() end,
      b = {
        function() end,
        function() end,
      },
      c = {
        [1] = function() end,
        x = function() end,
        y = function() end,
        z = {
          i = function() end,
          j = function() end,
        },
      },
    }

    it("works", function()
      local revert = helpers.stubs({ [funcs] = { "a" } })
      assert.equals(true, spy.is_spy(funcs.a))
      funcs.a()
      assert.spy(funcs.a).called(1)
      assert.spy(funcs.a).called_with()
      assert.spy(funcs.a).returned_with()
      -- Call a function that should clear all stubs
      after_each.calls[1].refs[1]()
      assert.spy(funcs.a).was_not_called()
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(false, spy.is_spy(funcs.b[1]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(false, spy.is_spy(funcs.c.x))
      assert.stub(after_each).called(1)
      assert.stub(after_each).called_with(match.is_function())
      revert()
      assert.equals(false, spy.is_spy(funcs.a))
      assert.equals("function", type(funcs.a))
    end)

    it("works with strings", function()
      local revert = helpers.stubs({ [funcs] = "a" })
      assert.equals(true, spy.is_spy(funcs.a))
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(false, spy.is_spy(funcs.b[1]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(false, spy.is_spy(funcs.c.x))
      revert()
      assert.equals(false, spy.is_spy(funcs.a))
      assert.equals("function", type(funcs.a))
    end)

    it("works for multiple functions to stub", function()
      local revert = helpers.stubs({
        [funcs] = "a",
        [funcs.c] = { "x", "y" },
      })
      assert.equals(true, spy.is_spy(funcs.a))
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(false, spy.is_spy(funcs.b[1]))
      assert.equals(false, spy.is_spy(funcs.b[2]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(false, spy.is_spy(funcs.c[1]))
      assert.equals(true, spy.is_spy(funcs.c.x))
      assert.equals(true, spy.is_spy(funcs.c.y))
      assert.equals(false, spy.is_spy(funcs.c.z))
      revert()
      assert.equals(false, spy.is_spy(funcs.a))
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(false, spy.is_spy(funcs.b[1]))
      assert.equals(false, spy.is_spy(funcs.b[2]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(false, spy.is_spy(funcs.c[1]))
      assert.equals(false, spy.is_spy(funcs.c.x))
      assert.equals(false, spy.is_spy(funcs.c.y))
      assert.equals(false, spy.is_spy(funcs.c.z))
    end)

    it("works with numeric keys", function()
      local revert = helpers.stubs({
        [funcs] = "a",
        [funcs.b] = { 1, 2 },
        [funcs.c] = 1,
      })
      assert.equals(true, spy.is_spy(funcs.a))
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(true, spy.is_spy(funcs.b[1]))
      assert.equals(true, spy.is_spy(funcs.b[2]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(true, spy.is_spy(funcs.c[1]))
      assert.equals(false, spy.is_spy(funcs.c.x))
      assert.equals(false, spy.is_spy(funcs.c.y))
      assert.equals(false, spy.is_spy(funcs.c.z))
      funcs.a()
      funcs.b[1]()
      funcs.c[1]()
      assert.spy(funcs.a).called(1)
      assert.spy(funcs.b[1]).called(1)
      assert.spy(funcs.c[1]).called(1)
      after_each.calls[1].refs[1]()
      assert.spy(funcs.a).was_not_called()
      assert.spy(funcs.b[1]).was_not_called()
      assert.spy(funcs.c[1]).was_not_called()
      revert()
      assert.equals(false, spy.is_spy(funcs.a))
      assert.equals(false, spy.is_spy(funcs.b))
      assert.equals(false, spy.is_spy(funcs.b[1]))
      assert.equals(false, spy.is_spy(funcs.b[2]))
      assert.equals(false, spy.is_spy(funcs.c))
      assert.equals(false, spy.is_spy(funcs.c[1]))
      assert.equals(false, spy.is_spy(funcs.c.x))
      assert.equals(false, spy.is_spy(funcs.c.y))
      assert.equals(false, spy.is_spy(funcs.c.z))
    end)

    -- Clear a module with stubbed functions
    after_each = after_each_orig
  end)
end)
