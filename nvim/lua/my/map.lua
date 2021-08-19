local map = {}

---@type function[]
function _G._call_map_function(id)
  return require("my.map").functions[id]()
end
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
  ---@param mode string[]|string
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table<string, boolean>
  local function map_fun(mode, lhs, rhs, opts)
    local final_opts = vim.tbl_extend("force", default_opts, opts or {})
    if type(mode) == "string" then
      mode = { mode }
    end
    if type(rhs) == "function" then
      local id = store_function(rhs)
      if final_opts.expr then
        rhs = string.format("v:lua._call_map_function(%s)", id)
      else
        rhs = string.format("<Cmd>lua require('my.map').functions[%s]()<CR>", id)
      end
    end
    for _, m in ipairs(mode) do
      set_keymap(m, lhs, rhs, final_opts)
    end
  end
  return map_fun
end

map.map = make_map({ noremap = true, silent = true })
map.map_expr = make_map({ noremap = true, silent = true, expr = true })
map.buf_map = make_map({ noremap = true, silent = true }, true)
map.buf_map_expr = make_map({ noremap = true, silent = true, expr = true }, true)

---Wrapper around vim.api.nvim_replace_termcodes
---@param str string
---@param do_lt boolean
---@return string
function map.replace_termcodes(str, do_lt)
  do_lt = do_lt == nil and false or true
  return vim.api.nvim_replace_termcodes(str, true, do_lt, true)
end

return map
