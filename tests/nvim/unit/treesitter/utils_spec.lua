describe("treesitter.utils", function()
  local utils = require("treesitter.utils")

  describe("get_captures_at_cursor", function()
    local get_captures_at_cursor = utils.get_captures_at_cursor
    local text = [[
-- Comment
if string.sub("hello", 1) then
  vim.cmd("setlocal tabstop=8 expandtab")
  print("Hello, world!")
end
]]
    local lines = vim.split(text, "\n", { plain = true })
    vim.treesitter.query.set_query(
      "lua",
      "test",
      [[
        (comment) @comment
        (string) @string
        (function_call
          (arguments) @fun_args)
        (if_statement
          consequence: (_) @if_block)
        (function_call
          name: (dot_index_expression) @vimcmd
          arguments: (arguments
            (string content: _ @vim))
          (#eq? @vimcmd "vim.cmd"))
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
  end)
end)
