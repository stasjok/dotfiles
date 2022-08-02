local buf_set_lines = vim.api.nvim_buf_set_lines
local win_set_cursor = vim.api.nvim_win_set_cursor

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
    buf_set_lines(0, 0, -1, true, vim.split(text, "\n", true))
    vim.opt.filetype = "lua"

    it("returns empty result without args", function()
      assert.are.same({}, get_captures_at_cursor())
    end)
  end)
end)
