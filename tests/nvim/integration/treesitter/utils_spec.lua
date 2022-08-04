-- TODO: Replace with upstreamed version from neovim 0.8
local get_node_at_cursor = require("nvim-treesitter.ts_utils").get_node_at_cursor
local feedkeys = require("map").feedkeys

describe("treesitter.utils", function()
  local utils = require("treesitter.utils")
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

  describe("get_captures_at_cursor", function()
    local get_captures_at_cursor = utils.get_captures_at_cursor

    it("returns empty result without args", function()
      ---@diagnostic disable-next-line: missing-parameter
      assert.are.same({}, get_captures_at_cursor())
    end)

    -- Create a new window in order to check that function can work for inactive windows
    local win = vim.api.nvim_get_current_win()
    vim.cmd("new")
    local second_win = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.api.nvim_set_current_win(win)

    it("works with all args for inactive windows", function()
      vim.api.nvim_win_set_cursor(second_win, { 1, 1 })
      assert.are_not.equal(vim.api.nvim_get_current_win(), second_win)
      assert.are_not.equal("lua", vim.bo.filetype)
      local captures = get_captures_at_cursor("test", second_win, "lua")
      assert.are.equal(1, #captures)
      assert.are.equal("comment", captures[1][1])
      assert.are.equal("comment", captures[1][2]:type())
    end)

    -- Destroy second window, other tests will be run in main window
    vim.api.nvim_buf_delete(vim.api.nvim_win_get_buf(second_win), { force = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.opt_local.filetype = "lua"

    it("works without optional args", function()
      vim.api.nvim_win_set_cursor(0, { 1, 1 })
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("comment", captures[1][1])
      assert.are.equal("comment", captures[1][2]:type())
    end)

    it("returns empty table outside captures", function()
      vim.api.nvim_win_set_cursor(0, { 2, 14 })
      assert.are.same({}, get_captures_at_cursor("test"))
    end)

    it("works on capture start", function()
      vim.api.nvim_win_set_cursor(0, { 2, 15 })
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("string_content", captures[1][1])
      assert.are.equal("string_content", captures[1][2]:type())
    end)

    it("works on capture end (inclusive)", function()
      vim.api.nvim_win_set_cursor(0, { 2, 19 })
      local captures = get_captures_at_cursor("test")
      assert.are.equal(1, #captures)
      assert.are.equal("string_content", captures[1][1])
      assert.are.equal("string_content", captures[1][2]:type())
    end)

    it("works after capture end", function()
      vim.api.nvim_win_set_cursor(0, { 2, 20 })
      assert.are.same({}, get_captures_at_cursor("test"))
    end)

    it("can return overlapping captures", function()
      vim.api.nvim_win_set_cursor(0, { 3, 12 })
      local captures = get_captures_at_cursor("test")
      assert.are.equal(2, #captures)
      table.sort(captures, function(a, b)
        return a[1] < b[1]
      end)
      assert.are.equal("if_block", captures[1][1])
      assert.are.equal("block", captures[1][2]:type())
      assert.are.equal("string_content", captures[2][1])
      assert.are.equal("string_content", captures[2][2]:type())
    end)

    describe("source_node", function()
      vim.api.nvim_win_set_cursor(0, { 3, 22 })
      -- String have three nodes (index from 0): start quote, string, end quote
      local source_node = get_node_at_cursor():child(1)
      assert.are.equal("setlocal tabstop=8 expandtab", vim.treesitter.get_node_text(source_node, 0))

      it("works with source_node", function()
        vim.api.nvim_win_set_cursor(0, { 3, 22 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.equal(1, #captures)
        assert.are.equal("option", captures[1][1])
        assert.are.equal("option_name", captures[1][2]:type())
        assert.are.equal(13, captures[1][3])
      end)

      it("works outside captures", function()
        vim.api.nvim_win_set_cursor(0, { 3, 12 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.same({}, captures)
      end)

      it("works before capture start", function()
        vim.api.nvim_win_set_cursor(0, { 3, 17 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.same({}, captures)
      end)

      it("works on capture start", function()
        vim.api.nvim_win_set_cursor(0, { 3, 18 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.equal(1, #captures)
        assert.are.equal("option", captures[1][1])
        assert.are.equal("option_name", captures[1][2]:type())
        assert.are.equal(9, captures[1][3])
      end)

      it("works on capture end (end-inclusive)", function()
        vim.api.nvim_win_set_cursor(0, { 3, 25 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.equal(1, #captures)
        assert.are.equal("option", captures[1][1])
        assert.are.equal("option_name", captures[1][2]:type())
        assert.are.equal(16, captures[1][3])
      end)

      it("works after capture start", function()
        vim.api.nvim_win_set_cursor(0, { 3, 26 })
        local captures = get_captures_at_cursor("test", 0, "vim", source_node)
        assert.are.same({}, captures)
      end)

      clear()
    end)
  end)

  describe("get_node_text_before_cursor", function()
    local get_node_text_before_cursor = utils.get_node_text_before_cursor
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.opt_local.filetype = "lua"
    vim.treesitter.get_parser():parse()

    it("works for oneline nodes", function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      local node = get_node_at_cursor(0, true) --[[@as table]]
      assert.are.equal("comment", node:type())

      assert.are.equal("", get_node_text_before_cursor(node, 0))
      vim.api.nvim_win_set_cursor(0, { 1, 1 })
      assert.are.equal("-", get_node_text_before_cursor(node, 0))
      vim.api.nvim_win_set_cursor(0, { 1, 4 })
      assert.are.equal("-- C", get_node_text_before_cursor(node, 0))
      -- Can't place cursor after last character in normal mode
      vim.api.nvim_win_set_cursor(0, { 1, 10 })
      -- Use visual mode to move cursor after last character
      feedkeys("vl", "x")
      assert.are.equal("-- Comment", get_node_text_before_cursor(node, 0))
      -- Leave visual mode
      feedkeys("<Esc>", "x")
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      assert.are.equal("-- Comment\n", get_node_text_before_cursor(node, 0))
      vim.api.nvim_win_set_cursor(0, { 2, 3 })
      assert.are.equal("-- Comment\nif ", get_node_text_before_cursor(node, 0))
    end)

    it("works for multiline nodes", function()
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      local node = get_node_at_cursor() --[[@as table]]
      assert.are.equal("if_statement", node:type())

      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      assert.are.equal("", get_node_text_before_cursor(node, win))
      vim.api.nvim_win_set_cursor(0, { 2, 2 })
      assert.are.equal("if", get_node_text_before_cursor(node, win))
      vim.api.nvim_win_set_cursor(0, { 3, 7 })
      assert.are.equal(
        'if string.sub("test", 1) then\n  print',
        get_node_text_before_cursor(node, win)
      )
    end)

    it("works for strings", function()
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      local node = get_node_at_cursor() --[[@as table]]
      assert.are.equal("if_statement", node:type())

      assert.are.equal("", get_node_text_before_cursor(node, text, 11))
      assert.are.equal("if", get_node_text_before_cursor(node, text, 13))
      assert.are.equal("if", get_node_text_before_cursor(node, text, 13))
      assert.are.equal('if string.sub("test", 1) then', get_node_text_before_cursor(node, text, 40))
      assert.are.equal(
        'if string.sub("test", 1) then\n  print',
        get_node_text_before_cursor(node, text, 48)
      )
    end)

    it("returns empty string if node is starting after cursor", function()
      vim.api.nvim_win_set_cursor(0, { 3, 4 })
      local node = get_node_at_cursor() --[[@as table]]
      assert.are.equal("identifier", node:type())

      vim.api.nvim_win_set_cursor(0, { 3, 2 })
      assert.are.equal("", get_node_text_before_cursor(node))
      vim.api.nvim_win_set_cursor(0, { 3, 1 })
      assert.are.equal("", get_node_text_before_cursor(node))
      vim.api.nvim_win_set_cursor(0, { 3, 0 })
      assert.are.equal("", get_node_text_before_cursor(node))
      vim.api.nvim_win_set_cursor(0, { 2, 4 })
      assert.are.equal("", get_node_text_before_cursor(node))
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      assert.are.equal("", get_node_text_before_cursor(node))
      assert.are.equal("", get_node_text_before_cursor(node, text, 42))
      assert.are.equal("", get_node_text_before_cursor(node, text, 40))
      assert.are.equal("", get_node_text_before_cursor(node, text, 4))
      assert.are.equal("", get_node_text_before_cursor(node, text, 0))
    end)
  end)
end)
