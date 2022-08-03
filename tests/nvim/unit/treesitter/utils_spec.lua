describe("treesitter.utils", function()
  local utils = require("treesitter.utils")

  describe("is_in_node_range", function()
    local is_in_node_range = utils.is_in_node_range
    -- Fake node
    local node = {
      range = function()
        return 1, 2, 3, 5
      end,
    }
    local node_singleline = {
      range = function()
        return 0, 4, 0, 7
      end,
    }

    it("returns false before node start", function()
      assert.is_false(is_in_node_range(node, 0, 10))
      assert.is_false(is_in_node_range(node, 1, 1))
    end)

    it("returns true at node start", function()
      assert.is_true(is_in_node_range(node, 1, 2))
    end)

    it("returns true on first line of the node", function()
      assert.is_true(is_in_node_range(node, 1, 2))
      assert.is_true(is_in_node_range(node, 1, 10))
      assert.is_true(is_in_node_range(node_singleline, 0, 4))
      assert.is_true(is_in_node_range(node_singleline, 0, 5))
    end)

    it("returns true between node lines", function()
      assert.is_true(is_in_node_range(node, 2, 0))
      assert.is_true(is_in_node_range(node, 2, 10))
    end)

    it("returns true on last line of the node", function()
      assert.is_true(is_in_node_range(node, 3, 0))
      assert.is_true(is_in_node_range(node, 3, 4))
      assert.is_true(is_in_node_range(node_singleline, 0, 6))
    end)

    it("returns false on node end (end-exclusive)", function()
      assert.is_false(is_in_node_range(node, 3, 5))
      assert.is_false(is_in_node_range(node, 3, 5, false))
      assert.is_false(is_in_node_range(node_singleline, 0, 7))
      assert.is_false(is_in_node_range(node_singleline, 0, 7, false))
    end)

    it("returns true on node end (end-inclusive)", function()
      assert.is_true(is_in_node_range(node, 3, 5, true))
      assert.is_true(is_in_node_range(node_singleline, 0, 7, true))
    end)

    it("returns false after node end", function()
      assert.is_false(is_in_node_range(node, 3, 6))
      assert.is_false(is_in_node_range(node_singleline, 0, 8))
      assert.is_false(is_in_node_range(node_singleline, 0, 10))
      assert.is_false(is_in_node_range(node, 4, 0))
      assert.is_false(is_in_node_range(node, 4, 10))
    end)
  end)
end)
