local minitest = require("mini.test")

local Child = {}

--- New Child options
---@class test.Child.new.Opts
---@field minimal? boolean Whether child is minimal

--- Creates a new Child object
---@param opts test.Child.new.Opts? Child options
---@return test.Child
function Child.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, { minimal = false })

  --- Child Nvim process
  ---@class test.Child: child
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

  -- Restart child, or start it if's not started yet
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

  ---@class test.Child.set_lines.Opts
  ---@field buf? integer Buffer handle, or 0 for current buffer
  ---@field start? integer First line index
  ---@field finish? integer Last line index, exclusive
  ---@field strict? boolean Whether out-of-bounds should be an error

  --- Set a line-range in the buffer of child neovim
  ---@param arr string[] | string
  ---@param opts? test.Child.set_lines.Opts
  ---@diagnostic disable-next-line: redefined-local
  child.set_lines = function(arr, opts)
    prevent_hanging("set_lines")

    if type(arr) == "string" then
      arr = vim.split(arr, "\n")
    end

    ---@type test.Child.set_lines.Opts
    opts = vim.tbl_extend("keep", opts or {}, {
      buf = 0,
      start = 0,
      finish = -1,
      strict = true,
    })

    child.api.nvim_buf_set_lines(opts.buf, opts.start, opts.finish, opts.strict, arr)
  end

  ---@class test.Child.get_lines.Opts: test.Child.set_lines.Opts
  ---@field join? boolean Whether to join lines into a string

  ---Get a line-range from the buffer of child neovim
  ---@param opts? test.Child.get_lines.Opts
  ---@return string[] | string
  ---@diagnostic disable-next-line: redefined-local
  child.get_lines = function(opts)
    prevent_hanging("get_lines")

    ---@type test.Child.get_lines.Opts
    opts = vim.tbl_extend("keep", opts or {}, {
      buf = 0,
      start = 0,
      finish = -1,
      strict = true,
      join = false,
    })

    local lines = child.api.nvim_buf_get_lines(opts.buf, opts.start, opts.finish, opts.strict)
    return opts.join and table.concat(lines, "\n") or lines
  end

  ---Sets the (1,0)-indexed cursor position in the window of the child neovim
  ---@param row integer Row number 1-indexed
  ---@param col integer Column number 0-indexed
  ---@param window integer? Window handler, or 0 for current window
  child.set_cursor = function(row, col, window)
    prevent_hanging("set_cursor")

    child.api.nvim_win_set_cursor(window or 0, { row, col })
  end

  ---Gets the (1,0)-indexed cursor position in the window of the child neovim
  ---@param window integer? Window handler, or 0 for current window
  ---@return integer row Row number 1-indexed
  ---@return integer col Column number 0-indexed
  child.get_cursor = function(window)
    prevent_hanging("get_cursor")

    return unpack(child.api.nvim_win_get_cursor(window or 0))
  end

  ---Sets the screen size of the child neovim
  ---@param columns integer Number of columns of the screen
  ---@param lines integer Number of lines of the screen
  child.set_size = function(columns, lines)
    prevent_hanging("set_size")

    child.o.columns = columns
    child.o.lines = lines
  end

  ---Gets the screen size of the child neovim
  ---@return integer columns Number of columns of the screen
  ---@return integer lines Number of lines of the screen
  child.get_size = function()
    prevent_hanging("get_size")

    return child.o.columns, child.o.lines
  end

  -- A trick to fool LuaLS into assigning types to the child methods
  if false then
    child.api = vim.api
    child.api_notify = vim.api
    child.fn = vim.fn
    -- Options
    child.o = vim.o
    child.go = vim.go
    child.bo = vim.bo
    child.wo = vim.wo
    -- Collections
    child.loop = vim.uv
    child.diagnostic = vim.diagnostic
    child.highlight = vim.highlight
    child.json = vim.json
    child.lsp = vim.lsp
    child.mpack = vim.mpack
    child.spell = vim.spell
    child.treesitter = vim.treesitter
    child.ui = vim.ui

    --- Child start options
    ---@class test.Child.start.Opts
    ---@field nvim_executable? string Nvim executable. Default: `v:progpath`
    ---@field connection_timeout? integer Stop trying to connect after thiw amount of milliseconds. Default: 5000

    --- Start child process
    ---@param args string[]? Arguments for executable
    ---@param opts test.Child.start.Opts? Child start options
    ---@diagnostic disable-next-line: redefined-local
    function child.start(args, opts)
      vim.print(args, opts)
    end

    --- Stop child process
    function child.stop() end

    --- Restart child process
    ---@param args string[]? Arguments for executable
    ---@param opts test.Child.start.Opts? Child start options
    ---@diagnostic disable-next-line: redefined-local
    function child.restart(args, opts)
      vim.print(args, opts)
    end

    --- Emulate typing keys
    ---@param wait integer|string|string[] Number of milliseconds to wait after each entry. May be omitted
    ---@param ... string|string[]
    function child.type_keys(wait, ...)
      vim.print(wait, ...)
    end

    --- Execute Vimscript code from a string
    ---@param str string Vimscript code
    ---@return ""
    function child.cmd(str)
      return str
    end

    --- Execute Vimscript code from a string and capture output
    ---@param str string Vimscript code
    ---@return string
    function child.cmd_capture(str)
      return str
    end

    --- Types allowed for RPC
    ---@alias test.Child.RPC_types vim.NIL|boolean|string|number|integer|table

    --- Execute lua code
    ---@param str string Lua code to execute
    ---@param args test.Child.RPC_types[]? Arguments to the code
    ---@return any #Return value of the Lua code if present or NIL
    ---@diagnostic disable-next-line: redefined-local
    function child.lua(str, args)
      vim.print(str, args)
    end

    --- Execute lua code without waiting for output
    ---@param str string Lua code to execute
    ---@param args test.Child.RPC_types[]? Arguments to the code
    ---@return any #Return value of the Lua code if present or NIL
    ---@diagnostic disable-next-line: redefined-local
    function child.lua_notify(str, args)
      vim.print(str, args)
    end

    --- Execute lua code and return result. Essentially it prepends the Lua code with `return`.
    ---@param str string Lua code to execute
    ---@param args test.Child.RPC_types[]? Arguments to the code
    ---@return any #Return value of the Lua code if present or NIL
    ---@diagnostic disable-next-line: redefined-local
    function child.lua_get(str, args)
      vim.print(str, args)
    end

    --- Execute lua function and return its result
    ---@generic T: test.Child.RPC_types, U: test.Child.RPC_types
    ---@param f fun(...: U): T?
    ---@param ... U
    ---@return T
    function child.lua_func(f, ...)
      return f(...)
    end

    --- Check whether child process is blocked
    ---@return boolean
    function child.is_blocked()
      return false
    end

    --- Check whether child process is currently running
    ---@return boolean
    function child.is_running()
      return true
    end

    --- Ensure normal mode
    function child.ensure_normal_mode() end

    --- Child get screenshot options
    ---@class test.Child.get_screenshot.Opts
    ---@field redraw? boolean Redraw pending screen updates prior to computing screenshot

    --- Child screenshot
    ---@class test.Child.screenshot
    ---@field text string[][]
    ---@field attr string[][]

    --- Compute what is displayed on screen and how it is displayed
    ---@param opts test.Child.get_screenshot.Opts? Get screenshot options
    ---@return test.Child.screenshot?
    ---@diagnostic disable-next-line: redefined-local
    function child.get_screenshot(opts)
      vim.print(opts)
    end
  end

  child.uv = child.loop

  return child
end

return Child
