local minitest = require("mini.test")

local Child = {}

--- New Child options
---@class test.Child.new.opts
---@field minimal? boolean Whether child is minimal

--- Creates a new Child object
---@param opts test.Child.new.opts? Child options
---@return test.Child
function Child.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, { minimal = false })

  --- Child Nvim process
  ---@class test.Child: MiniTest.child
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
    local init = assert(vim.env.initFile, "No 'initFile' environment variable defined")
    args = { "-u", init }
  end

  -- Restart child, or start it if's not started yet
  child.setup = function()
    child.restart(args, { nvim_executable = "nvim" })
  end

  --- Reset Nvim. This essentially wipes all buffers and windows.
  child.clear = function()
    child.prevent_hanging("clear")

    child.cmd("%bwipeout!")
    child.ensure_normal_mode()
    child.cmd.messages("clear")
  end

  ---A wrapper for `nvim_feedkeys()`.
  ---This is a blocking code, unlike `child.type_keys()`
  ---@param ... string | string[]
  child.feed_keys = function(...)
    child.prevent_hanging("feed_keys")

    local keys = vim.iter({ ... }):flatten():map(vim.keycode):join("")

    local prev_errmsg = child.v.errmsg
    child.v.errmsg = ""

    child.api.nvim_feedkeys(keys, "L", false)

    if not child.is_blocked() then
      if child.v.errmsg ~= "" then
        error(child.v.errmsg, 2)
      else
        child.v.errmsg = prev_errmsg
      end
    end
  end

  ---@class test.Child.set_lines.opts
  ---@field buf? integer Buffer handle, or 0 for current buffer
  ---@field start? integer First line index
  ---@field finish? integer Last line index, exclusive
  ---@field strict? boolean Whether out-of-bounds should be an error

  --- Set a line-range in the buffer of child neovim
  ---@param arr string[] | string
  ---@param opts? test.Child.set_lines.opts
  ---@diagnostic disable-next-line: redefined-local
  child.set_lines = function(arr, opts)
    child.prevent_hanging("set_lines")

    if type(arr) == "string" then
      arr = vim.split(arr, "\n")
    end

    ---@type test.Child.set_lines.opts
    opts = vim.tbl_extend("keep", opts or {}, {
      buf = 0,
      start = 0,
      finish = -1,
      strict = true,
    })

    child.api.nvim_buf_set_lines(opts.buf, opts.start, opts.finish, opts.strict, arr)
  end

  ---@class test.Child.get_lines.opts: test.Child.set_lines.opts
  ---@field join? boolean Whether to join lines into a string

  ---Get a line-range from the buffer of child neovim
  ---@param opts? test.Child.get_lines.opts
  ---@return string[] | string
  ---@diagnostic disable-next-line: redefined-local
  child.get_lines = function(opts)
    child.prevent_hanging("get_lines")

    ---@type test.Child.get_lines.opts
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
    child.prevent_hanging("set_cursor")

    child.api.nvim_win_set_cursor(window or 0, { row, col })
  end

  ---Gets the (1,0)-indexed cursor position in the window of the child neovim
  ---@param window integer? Window handler, or 0 for current window
  ---@return integer row Row number 1-indexed
  ---@return integer col Column number 0-indexed
  child.get_cursor = function(window)
    child.prevent_hanging("get_cursor")

    return unpack(child.api.nvim_win_get_cursor(window or 0))
  end

  ---Sets the screen size of the child neovim
  ---@param columns integer Number of columns of the screen
  ---@param lines integer Number of lines of the screen
  child.set_size = function(columns, lines)
    child.prevent_hanging("set_size")

    child.o.columns = columns
    child.o.lines = lines
  end

  ---Gets the screen size of the child neovim
  ---@return integer columns Number of columns of the screen
  ---@return integer lines Number of lines of the screen
  child.get_size = function()
    child.prevent_hanging("get_size")

    return child.o.columns, child.o.lines
  end

  --- Disable LSP servers autostart
  child.disable_lsp_autostart = function()
    child.prevent_hanging("disable_lsp_autostart")

    -- nvim-lspconfig
    child.api.nvim_clear_autocmds({ group = "lspconfig" })
    child.lua_func(function()
      for _, server in ipairs(require("lspconfig.util").available_servers()) do
        require("lspconfig")[server].autostart = false
      end
    end)

    -- none-ls.nvim
    child.lua([[require("null-ls").disable({})]])

    -- vim.lsp.config
    child.lua([[vim.iter(vim.tbl_keys(vim.lsp._enabled_configs)):each(function(name)
      vim.lsp.enable(name, false)
    end)]])
  end

  return child
end

return Child
