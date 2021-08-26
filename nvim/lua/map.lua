local map = {}

---@type function[]
map.functions = {}

---Store mapping functions in container
---@param fun function
---@return number
local function store_function(fun)
  table.insert(map.functions, fun)
  return #map.functions
end

---Returns a function for setting global or buffer mappings with default opts
---@param default_opts table<string, boolean>
---@param buffer boolean
---@return fun(mode: string|string[], lhs: string, rhs: string|function, opts?:table<string, boolean>)
local function make_map(default_opts, buffer)
  local set_keymap = vim.api.nvim_set_keymap
  if buffer then
    -- Wrap nvim_buf_set_keymap for current buffer
    set_keymap = function(mode, lhs, rhs, opts)
      vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
    end
  end
  ---Set keymap
  ---@param mode string[]|string Mode short-name (like "n", "i", "!", "") or array of modes
  ---@param lhs string Left-hand-side of the mapping
  ---@param rhs string|function Right-hand-side of the mapping. Can be lua function
  ---@param opts? table<string, boolean> Optional parameters map. Default: {noremap = true, silent = true}
  local function map_fun(mode, lhs, rhs, opts)
    local final_opts = vim.tbl_extend("force", default_opts, opts or {})
    if type(mode) == "string" then
      mode = { mode }
    end
    if type(rhs) == "function" then
      local id = store_function(rhs)
      if final_opts.expr then
        rhs = string.format([[luaeval('require("map").functions[%s]()')]], id)
      else
        rhs = string.format("<Cmd>lua require('map').functions[%s]()<CR>", id)
      end
    end
    for _, m in ipairs(mode) do
      set_keymap(m, lhs, rhs, final_opts)
    end
  end
  return map_fun
end

---Set a global mapping for the given mode
map.map = make_map({ noremap = true, silent = true })
---Set a global mapping for the given mode whose argument is an expression
map.map_expr = make_map({ noremap = true, silent = true, expr = true })
---Set a buffer-local mapping for current buffer
map.buf_map = make_map({ noremap = true, silent = true }, true)
---Set a buffer-local mapping for current buffer whose argument is an expression
map.buf_map_expr = make_map({ noremap = true, silent = true, expr = true }, true)

---A wrapper around `vim.api.nvim_replace_termcodes()`
---@param str string String to be converted
---@param do_lt? boolean Also translate <lt>. Default: false
---@return string #Converted string
function map.replace_termcodes(str, do_lt)
  return vim.api.nvim_replace_termcodes(str, true, do_lt, true)
end

---Defer execution of a function whose return value will be converted with `vim.api.nvim_replace_termcodes()`
---@param fun function A function whose return value will be converted
---@param do_lt? boolean Also translate <lt>. Default: false
---@return function #A wrapped function
function map.replace_termcodes_wrap(fun, do_lt)
  return function()
    return vim.api.nvim_replace_termcodes(fun(), true, do_lt, true)
  end
end

return map
