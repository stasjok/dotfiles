local minitest = require("mini.test")

local Child = {}

-- Modified new_child_neovim()
function Child.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, { minimal = false })

  local child = minitest.new_child_neovim()

  local args
  if opts.minimal then
    args = {
      "-u",
      "tests/nvim/minimal_init.lua",
      "--noplugin",
      "--cmd",
      "let g:did_load_ftplugin = 1 | let g:did_indent_on = 1",
    }
  else
    args = { "-u", "~/.config/nvim/init.lua" }
  end

  child.setup = function()
    child.restart(args, { nvim_executable = "nvim" })
  end

  local prevent_hanging = function(method)
    if not child.is_blocked() then
      return
    end

    local msg = string.format("Can not use `child.%s` because child process is blocked.", method)
    error(msg)
  end

  ---@alias ChildSetLinesOpts { buf?: number, start?: number, finish?: number, strict?: boolean }

  ---Set a line-range in the buffer of child neovim
  ---@param arr string[] | string
  ---@param opts? ChildSetLinesOpts
  ---@diagnostic disable-next-line: redefined-local
  child.set_lines = function(arr, opts)
    prevent_hanging("set_lines")

    if type(arr) == "string" then
      arr = vim.split(arr, "\n")
    end

    opts = vim.tbl_extend("keep", opts or {}, {
      buf = 0,
      start = 0,
      finish = -1,
      strict = true,
    }) --[[@as ChildSetLinesOpts]]

    child.api.nvim_buf_set_lines(opts.buf, opts.start, opts.finish, opts.strict, arr)
  end

  ---@alias ChildGetLinesOpts { buf?: number, start?: number, finish?: number, strict?: boolean, join?: boolean }

  ---Get a line-range from the buffer of child neovim
  ---@param opts? ChildGetLinesOpts
  ---@return string[] | string
  ---@diagnostic disable-next-line: redefined-local
  child.get_lines = function(opts)
    prevent_hanging("get_lines")

    opts = vim.tbl_extend("keep", opts or {}, {
      buf = 0,
      start = 0,
      finish = -1,
      strict = true,
      join = false,
    }) --[[@as ChildGetLinesOpts]]

    local lines = child.api.nvim_buf_get_lines(opts.buf, opts.start, opts.finish, opts.strict)
    return opts.join and table.concat(lines, "\n") or lines
  end

  ---Sets the (1,0)-indexed cursor position in the window of the child neovim
  ---@param row integer
  ---@param col integer
  ---@param window integer
  child.set_cursor = function(row, col, window)
    prevent_hanging("set_cursor")

    child.api.nvim_win_set_cursor(window or 0, { row, col })
  end

  ---Gets the (1,0)-indexed cursor position in the window of the child neovim
  ---@param window integer
  ---@return integer row
  ---@return integer col
  child.get_cursor = function(window)
    prevent_hanging("get_cursor")

    return unpack(child.api.nvim_win_get_cursor(window or 0))
  end

  ---Sets the screen size of the child neovim
  ---@param columns integer
  ---@param lines integer
  child.set_size = function(columns, lines)
    prevent_hanging("set_size")

    child.o.columns = columns
    child.o.lines = lines
  end

  ---Gets the screen size of the child neovim
  ---@return integer columns
  ---@return integer lines
  child.get_size = function()
    prevent_hanging("get_size")

    return child.o.columns, child.o.lines
  end

  return child
end

return Child
