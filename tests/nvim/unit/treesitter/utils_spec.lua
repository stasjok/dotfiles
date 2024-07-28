local assert = require("luassert")
local stub = require("luassert.stub")
local match = require("luassert.match")

describe("treesitter.utils", function()
  local utils

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
      "get_node_text",
    },
    [vim.treesitter.query] = {
      "get",
    },
    [_G.package.loaded.utils] = {
      "get_cursor_0",
    },
  }

  setup(function()
    -- Create stubs
    for module, keys in pairs(stubs) do
      for _, key in ipairs(keys) do
        stub.new(module, key)
      end
    end

    -- Load tested module
    _G._IS_TEST = true
    utils = require("treesitter.utils")
  end)

  teardown(function()
    -- Revert stubs
    for module, keys in pairs(stubs) do
      for _, key in ipairs(keys) do
        module[key]:revert()
      end
    end
  end)

  -- Clear stubs
  before_each(function()
    for module, keys in pairs(stubs) do
      for _, key in ipairs(keys) do
        module[key]:clear()
      end
    end
  end)

  describe("is_in_node_range", function()
    local is_in_node_range

    setup(function()
      is_in_node_range = utils.is_in_node_range
    end)

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
    local get_cursor_relative_to_node
    local node = {
      start = function()
        return 1, 4, 14
      end,
    }

    setup(function()
      -- Pretend that every line is 10 chars long
      vim.api.nvim_buf_get_offset.invokes(function(_, line)
        return line * 10
      end)

      get_cursor_relative_to_node = utils.get_cursor_relative_to_node
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
    local get_captures_at_cursor
    local get_cursor_0

    setup(function()
      get_captures_at_cursor = utils.get_captures_at_cursor
      get_cursor_0 = _G.package.loaded.utils.get_cursor_0
      stub.new(utils, "is_in_node_range", false)
    end)

    teardown(function()
      utils.is_in_node_range:revert()
    end)

    after_each(function()
      utils.is_in_node_range:clear()
    end)

    ---Compare capture pairs for table.sort
    ---@param a {[1]: string, [2]: table, [3]?: integer}
    ---@param b {[1]: string, [2]: table, [3]?: integer}
    ---@return boolean
    local function captures_comp(a, b)
      return a[1] < b[1]
    end

    local parsed = {
      { root = stub.new(nil, nil, "tree_root1") },
      { root = stub.new() },
      { root = stub.new(nil, nil, "tree_root2") },
    }

    -- Query with empty iterator by default
    local query = {
      captures = { "capture1", "capture2", "capture3" },
      iter_captures = stub(nil, nil, function()
        return function()
          return nil
        end
      end),
    }

    it("does not error if there is no parser", function()
      vim.treesitter.get_parser.invokes(function()
        error("Failed to load parser")
      end)

      assert.has_no.errors(function()
        get_captures_at_cursor("test")
      end)
    end)

    it("returns empty table if there is no parser", function()
      vim.treesitter.get_parser.returns()

      ---@diagnostic disable-next-line: missing-parameter
      assert.are.same({}, get_captures_at_cursor())
      assert.stub(vim.treesitter.get_parser).is.called(1)
      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(vim.treesitter.get_parser).is.called(2)
    end)

    it("returns empty table if there is no trees", function()
      vim.treesitter.get_parser.returns({
        parse = function()
          return {}
        end,
      })

      assert.are.same({}, get_captures_at_cursor("test"))
      assert.stub(vim.treesitter.get_parser).is.called(1)
    end)

    describe("sub", function()
      after_each(function()
        for _, tree in ipairs(parsed) do
          tree.root:clear()
        end
      end)

      it("returns empty table if cursor is not in any tree range", function()
        vim.treesitter.get_parser.returns({
          parse = function()
            return parsed
          end,
        })

        assert.are.same({}, get_captures_at_cursor("test"))
        assert.stub(parsed[1].root).is.called(1)
        assert.stub(parsed[2].root).is.called(1)
        assert.stub(parsed[3].root).is.called(1)
        assert.stub(utils.is_in_node_range).is.called(2)
        assert.stub(vim.treesitter.query.get).is_not.called()
      end)

      it("can find current tree", function()
        utils.is_in_node_range.on_call_with("tree_root2", match._, match._).returns(true)
        assert.are.same({}, get_captures_at_cursor("test"))
        assert.stub(parsed[1].root).is.called(1)
        assert.stub(parsed[2].root).is.called(1)
        assert.stub(parsed[3].root).is.called(1)
        assert.stub(utils.is_in_node_range).is.called(2)
        assert.stub(vim.treesitter.query.get).is.called(1)
      end)

      it("can short-circuit during finding current tree", function()
        utils.is_in_node_range.on_call_with("tree_root1", match._, match._).returns(true)
        assert.are.same({}, get_captures_at_cursor("test"))
        assert.stub(parsed[1].root).is.called(1)
        assert.stub(parsed[2].root).is_not.called()
        assert.stub(parsed[3].root).is_not.called()
        assert.stub(utils.is_in_node_range).is.called(1)
        assert.stub(vim.treesitter.query.get).is.called(1)
      end)

      it("returns empty table if captures are not found", function()
        vim.treesitter.query.get.returns(query)
        -- Current window
        vim.api.nvim_win_get_buf.on_call_with(0).returns(2)
        vim.api.nvim_buf_get_option.on_call_with(2, "filetype").returns("lua")
        get_cursor_0.on_call_with(0).returns(1, 4)

        assert.are.same({}, get_captures_at_cursor("test"))
        assert.stub(vim.treesitter.query.get).is.called_with("lua", "test")
        assert.stub(query.iter_captures).is.called_with(match._, "tree_root1", 2, 1, 2)
        assert.stub(utils.is_in_node_range).is.called(1)
      end)

      it("returns empty table if captures are found, but not on cursor", function()
        query.iter_captures
          .on_call_with(match._, "tree_root1", 2, 1, 2)
          .returns(pairs({ [1] = "node1", [3] = "node3" }))

        assert.are.same({}, get_captures_at_cursor("test1", nil, "lang"))
        assert.stub(vim.treesitter.query.get).is.called_with("lang", "test1")
        assert.stub(query.iter_captures).is.called_with(match._, "tree_root1", 2, 1, 2)
        assert.stub(utils.is_in_node_range).is.called(3)
      end)

      it("returns matches only in node range", function()
        utils.is_in_node_range.on_call_with("node3", 1, 4, true).returns(true)
        assert.are.same({ { "capture3", "node3" } }, get_captures_at_cursor("test"))
        assert.stub(vim.treesitter.query.get).is.called_with("lua", "test")
        assert.stub(query.iter_captures).is.called_with(match._, "tree_root1", 2, 1, 2)
        assert.stub(utils.is_in_node_range).is.called(3)
      end)

      it("returns matches for specific windows", function()
        -- Second window
        vim.api.nvim_win_get_buf.on_call_with(1003).returns(3)
        vim.api.nvim_buf_get_option.on_call_with(3, "filetype").returns("vim")
        get_cursor_0.on_call_with(1003).returns(2, 5)
        query.iter_captures
          .on_call_with(match._, "tree_root1", 3, 2, 3)
          .returns(pairs({ [1] = "node1", [2] = "node2", [3] = "node3" }))
        utils.is_in_node_range.on_call_with("node2", 2, 5, true).returns(true)
        utils.is_in_node_range.on_call_with("node3", 2, 5, true).returns(true)

        local captures = get_captures_at_cursor("test", 1003)
        table.sort(captures, captures_comp)
        assert.are.same({
          { "capture2", "node2" },
          { "capture3", "node3" },
        }, captures)
        assert.stub(vim.treesitter.query.get).is.called_with("vim", "test")
        assert.stub(query.iter_captures).is.called_with(match._, "tree_root1", 3, 2, 3)
        assert.stub(utils.is_in_node_range).is.called(4)
      end)

      it("works for window", function()
        utils.is_in_node_range.on_call_with("node1", 2, 5, true).returns(true)
        local captures = get_captures_at_cursor("query", 1003, "type")
        table.sort(captures, captures_comp)
        assert.are.same({
          { "capture1", "node1" },
          { "capture2", "node2" },
          { "capture3", "node3" },
        }, captures)
        assert.stub(vim.treesitter.query.get).is.called_with("type", "query")
      end)
    end)

    describe("source_node", function()
      local get_cursor_0

      setup(function()
        get_cursor_0 = _G.package.loaded.utils.get_cursor_0
      end)

      local source_node = {
        start = function()
          return 4, 1, 41
        end,
      }

      it("can find captures inside source node", function()
        vim.api.nvim_win_get_buf.on_call_with(1004).returns(4)
        vim.api.nvim_buf_get_option.on_call_with(4, "filetype").returns("lua")
        get_cursor_0.on_call_with(1004).returns(4, 3)
        vim.treesitter.get_node_text.returns("source_node_text")
        vim.treesitter.get_string_parser.returns({
          parse = function()
            return parsed
          end,
        })
        query.iter_captures
          .on_call_with(match._, "tree_root1", "source_node_text", 0, 1)
          .returns(pairs({ [1] = "node1" }))
        utils.is_in_node_range.on_call_with("node1", 0, 2, true).returns(true)

        assert.are.same(
          { { "capture1", "node1", 2 } },
          get_captures_at_cursor("test", 1004, nil, source_node)
        )
        assert.stub(vim.treesitter.get_node_text).was.called_with(source_node, 4)
        assert.stub(vim.treesitter.get_string_parser).was.called_with("source_node_text", "lua")
        assert.stub(utils.is_in_node_range).was.called_with("node1", 0, 2, true)
      end)

      it("can fine multiple captures inside source node", function()
        vim.api.nvim_win_get_buf.on_call_with(1005).returns(4)
        get_cursor_0.on_call_with(1005).returns(5, 0)
        query.iter_captures
          .on_call_with(match._, "tree_root1", "source_node_text", 1, 2)
          .returns(pairs({ [1] = "node1", [2] = "node2" }))
        utils.is_in_node_range.on_call_with("node1", 1, 0, true).returns(true)
        utils.is_in_node_range.on_call_with("node2", 1, 0, true).returns(true)

        local captures = get_captures_at_cursor("test", 1005, "vim", source_node)
        table.sort(captures, captures_comp)
        assert.are.same({
          { "capture1", "node1", 9 },
          { "capture2", "node2", 9 },
        }, captures)
        assert.stub(vim.treesitter.get_node_text).was.called_with(source_node, 4)
        assert.stub(vim.treesitter.get_string_parser).was.called_with("source_node_text", "vim")
        assert.stub(utils.is_in_node_range).was.called_with("node1", 1, 0, true)
        assert.stub(utils.is_in_node_range).was.called_with("node2", 1, 0, true)
      end)
    end)
  end)

  describe("get_node_text_before_cursor", function()
    local get_node_text_before_cursor
    local get_cursor_0

    setup(function()
      get_node_text_before_cursor = utils.get_node_text_before_cursor
      get_cursor_0 = _G.package.loaded.utils.get_cursor_0
    end)

    local function get_node(start_row, start_col, start_byte)
      return {
        start = function()
          return start_row, start_col, start_byte
        end,
      }
    end

    it("returns text from node start to cursor in window", function()
      -- Stub's returns for window 0 is defined earlier: buf = 2, cursor = 1, 4
      vim.api.nvim_buf_get_text.returns({ "line1" })
      assert.are.equal("line1", get_node_text_before_cursor(get_node(0, 3, 3)))
      assert.stub(vim.api.nvim_buf_get_text).was.called_with(2, 0, 3, 1, 4, match._)
    end)

    it("returns text from node start to cursor in another window", function()
      vim.api.nvim_win_get_buf.on_call_with(1100).returns(10)
      get_cursor_0.on_call_with(1100).returns(6, 1)

      vim.api.nvim_buf_get_text.returns({ "line1", "line2", "", "line4", "" })
      assert.are.equal(
        "line1\nline2\n\nline4\n",
        get_node_text_before_cursor(get_node(3, 8, 12), 1100)
      )
      assert.stub(vim.api.nvim_buf_get_text).was.called_with(10, 3, 8, 6, 1, match._)
    end)

    it("returns one symbol if cursor is directly after node start", function()
      vim.api.nvim_buf_get_text.returns({ "c" })
      assert.are.equal("c", get_node_text_before_cursor(get_node(6, 0, 12), 1100))
      assert.stub(vim.api.nvim_buf_get_text).was.called_with(10, 6, 0, 6, 1, match._)
    end)

    it("returns empty string if node start is after cursor", function()
      assert.are.equal("", get_node_text_before_cursor(get_node(6, 2, 12), 1100))
      assert.are.equal("", get_node_text_before_cursor(get_node(6, 20, 12), 1100))
      assert.are.equal("", get_node_text_before_cursor(get_node(7, 1, 12), 1100))
      assert.stub(vim.api.nvim_buf_get_text).was_not.called()
    end)

    it("returns empty string if node start is at cursor", function()
      vim.api.nvim_buf_get_text.returns({ "" })
      assert.are.equal("", get_node_text_before_cursor(get_node(6, 1, 12), 1100))
      assert.stub(vim.api.nvim_buf_get_text).was.called_with(10, 6, 1, 6, 1, match._)
    end)

    it("can return text from text source", function()
      assert.are.equal("a", get_node_text_before_cursor(get_node(0, 0, 0), "abc", 1))
      assert.are.equal("ab", get_node_text_before_cursor(get_node(0, 0, 0), "abc", 2))
      assert.are.equal("bc", get_node_text_before_cursor(get_node(0, 1, 1), "abc", 3))
      assert.are.equal("cdef", get_node_text_before_cursor(get_node(0, 2, 2), "abcdef", 30))
      assert.are.equal("b", get_node_text_before_cursor(get_node(1, 1, 6), "1234\nabcd", 7))
      assert.stub(vim.api.nvim_buf_get_text).was_not.called()
    end)

    it("returns empty string if cursor_byte equals node start byte", function()
      assert.are.equal("", get_node_text_before_cursor(get_node(0, 3, 3), "abcd", 3))
      assert.stub(vim.api.nvim_buf_get_text).was_not.called()
    end)

    it("returns empty string if cursor_byte is less than node start byte", function()
      assert.are.equal("", get_node_text_before_cursor(get_node(0, 3, 3), "abcd", 2))
      assert.stub(vim.api.nvim_buf_get_text).was_not.called()
    end)
  end)

  _G._IS_TEST = nil
end)
