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

  describe("get_captures_at_cursor", function()
    local get_captures_at_cursor = utils.get_captures_at_cursor
    local text = [[
-- Comment
if string.sub("test", 1) then
  print("setlocal tabstop=8 expandtab")
end
]]
    local lines = vim.split(text, "\n", { plain = true })
    vim.treesitter.query.set_query(
      "lua",
      "test",
      [[
        (comment) @comment
        (string content: _ @string_content)
        (if_statement
          consequence: (_) @if_block)
      ]]
    )
    vim.treesitter.query.set_query("vim", "test", "(set_item option: (option_name) @option)")

    -- vim.treesitter.get_parser fails with empty filetype
    vim.opt_local.filetype = "vim"

    it("returns empty result without args", function()
      ---@diagnostic disable-next-line: missing-parameter
      assert.are.same({}, get_captures_at_cursor())
    end)

    -- Create a new window in order to check that function can work for inactive windows
    local win = vim.api.nvim_get_current_win()
    vim.cmd("new")
    local second_win = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.api.nvim_win_set_cursor(second_win, { 1, 1 })
    vim.api.nvim_set_current_win(win)

    it("works with all args for inactive windows", function()
      assert.are_not.equal(vim.api.nvim_get_current_win(), second_win)
      assert.are_not.equal("lua", vim.bo.filetype)
      local captures = get_captures_at_cursor("test", second_win, "lua")
      assert.are.equal(1, #captures)
      assert.are.equal("comment", captures[1][1])
      assert.are.equal("comment", captures[1][2]:type())
    end)

    vim.api.nvim_buf_delete(vim.api.nvim_win_get_buf(second_win), { force = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.opt_local.filetype = "lua"
    vim.api.nvim_win_set_cursor(0, { 1, 1 })

    it("works without optional args", function()
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("comment", captures[1][1])
      assert.are.equal("comment", captures[1][2]:type())
    end)

    vim.api.nvim_win_set_cursor(0, { 2, 14 })

    it("returns empty table outside captures", function()
      assert.are.same({}, get_captures_at_cursor("test"))
    end)

    vim.api.nvim_win_set_cursor(0, { 2, 15 })

    it("works on capture start", function()
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("string_content", captures[1][1])
      assert.are.equal("string_content", captures[1][2]:type())
    end)

    vim.api.nvim_win_set_cursor(0, { 2, 19 })

    it("works on capture end (inclusive)", function()
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("string_content", captures[1][1])
      assert.are.equal("string_content", captures[1][2]:type())
    end)

    vim.api.nvim_win_set_cursor(0, { 2, 20 })

    it("works after capture end", function()
      assert.are.same({}, get_captures_at_cursor("test"))
    end)
  end)
end)
