describe("treesitter.utils", function()
  local stub = require("luassert.stub")
  -- Preload modules in order to replace it with stubs
  require("utils")
  -- List of stubs
  local stubs = {
    [vim.api] = {
      "nvim_buf_get_option",
      "nvim_win_get_buf",
      "nvim_buf_get_text",
      "nvim_buf_get_offset",
    },
    [vim.treesitter] = {
      "get_parser",
      "get_string_parser",
      "get_query",
      "get_node_text",
    },
    [_G.package.loaded.utils] = {
      "get_cursor_0",
    },
  }
  -- Create stubs
  for module, keys in pairs(stubs) do
    for _, key in ipairs(keys) do
      stub.new(module, key)
    end
  end

  -- Clear stubs
  before_each(function()
    for module, keys in pairs(stubs) do
      for _, key in ipairs(keys) do
        module[key]:clear()
      end
    end
  end)

  -- Load tested module
  _G._IS_TEST = true
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

  describe("get_cursor_relative_to_node", function()
    local get_cursor_relative_to_node = utils.get_cursor_relative_to_node
    local node = {
      start = function()
        return 1, 4, 14
      end,
    }
    -- Pretend that every line is 10 chars long
    vim.api.nvim_buf_get_offset.invokes(function(_, line)
      return line * 10
    end)

    it("returns zeroes before node start", function()
      assert.are.same({ 0, 0, 0 }, { get_cursor_relative_to_node(node, 0, 0) })
      assert.are.same({ 0, 0, 0 }, { get_cursor_relative_to_node(node, 0, 10) })
      assert.are.same({ 0, 0, 0 }, { get_cursor_relative_to_node(node, 1, 3) })
    end)

    it("returns zeroes on node start", function()
      assert.are.same({ 0, 0, 0 }, { get_cursor_relative_to_node(node, 1, 4) })
    end)

    it("returns correct position on first line of the node", function()
      assert.are.same({ 0, 1, 1 }, { get_cursor_relative_to_node(node, 1, 5) })
      assert.are.same({ 0, 6, 6 }, { get_cursor_relative_to_node(node, 1, 10) })
    end)

    it("returns correct position after first line of node start", function()
      assert.are.same({ 1, 0, 6 }, { get_cursor_relative_to_node(node, 2, 0) })
      assert.are.same({ 1, 10, 16 }, { get_cursor_relative_to_node(node, 2, 10) })
      assert.are.same({ 2, 5, 21 }, { get_cursor_relative_to_node(node, 3, 5) })
    end)
  end)

  describe("get_captures_at_cursor", function()
    local get_captures_at_cursor = utils.get_captures_at_cursor

    stub.new(utils, "is_in_node_range", false)
    after_each(function()
      utils.is_in_node_range:clear()
    end)

    vim.treesitter.get_parser.invokes(function()
      error("Failed to load parser")
    end)

    it("does not error if there is no parser", function()
      assert.has_no.errors(function()
        get_captures_at_cursor("test")
      end)
    end)

    vim.treesitter.get_parser.returns()

    it("returns empty table if there is no parser", function()
      ---@diagnostic disable-next-line: missing-parameter
      assert.are.same({}, get_captures_at_cursor())
      assert.stub(vim.treesitter.get_parser).is.called(1)
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(vim.treesitter.get_parser).is.called(2)
    end)

    vim.treesitter.get_parser.returns({
      parse = function()
        return {}
      end,
    })

    it("returns empty table if there is no trees", function()
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(vim.treesitter.get_parser).is.called(1)
    end)

    local parsed = {
      { root = stub.new(nil, nil, "tree_root1") },
      { root = stub.new() },
      { root = stub.new(nil, nil, "tree_root2") },
    }
    vim.treesitter.get_parser.returns({
      parse = function()
        return parsed
      end,
    })
    after_each(function()
      for _, tree in ipairs(parsed) do
        tree.root:clear()
      end
    end)

    it("returns empty table if cursor is not in any tree range", function()
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(parsed[1].root).is.called(1)
      assert.stub(parsed[2].root).is.called(1)
      assert.stub(parsed[3].root).is.called(1)
      assert.stub(utils.is_in_node_range).is.called(2)
      assert.stub(vim.treesitter.get_query).is_not.called()
    end)

    -- row, col are nils, because nvim_win_get_cursor is stub
    utils.is_in_node_range.on_call_with("tree_root2", nil, nil).returns(true)

    it("can find current tree", function()
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(parsed[1].root).is.called(1)
      assert.stub(parsed[2].root).is.called(1)
      assert.stub(parsed[3].root).is.called(1)
      assert.stub(utils.is_in_node_range).is.called(2)
      assert.stub(vim.treesitter.get_query).is.called(1)
    end)

    utils.is_in_node_range.on_call_with("tree_root1", nil, nil).returns(true)
    utils.is_in_node_range.on_call_with("tree_root2", nil, nil).returns(false)

    it("can short-circuit during finding current tree", function()
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(parsed[1].root).is.called(1)
      assert.stub(parsed[2].root).is_not.called()
      assert.stub(parsed[3].root).is_not.called()
      assert.stub(utils.is_in_node_range).is.called(1)
      assert.stub(vim.treesitter.get_query).is.called(1)
    end)

    utils.is_in_node_range:revert()
  end)

  -- Revert stubs
  for module, keys in pairs(stubs) do
    for _, key in ipairs(keys) do
      module[key]:revert()
    end
  end

  _G._IS_TEST = nil
end)
