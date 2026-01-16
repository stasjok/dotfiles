local luasnip = require("luasnip")
local extend_load_ft = require("luasnip.extras.filetype_functions").extend_load_ft
local jinja_ft_func = require("snippets.jinja_utils").jinja_ft_func

---@type fun(): string[] Returns a list of snippet filetypes for current cursor position
local ft_func = setmetatable({
  jinja = jinja_ft_func("jinja"),
  salt = jinja_ft_func("salt"),
  ansible = jinja_ft_func("ansible"),
  lua = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name:sub(-9, #buf_name) == "_spec.lua" then
      return { "lua", "lua_spec" }
    else
      return { "lua" }
    end
  end,
}, {
  __call = function(tbl)
    local filetypes = {}
    for ft in vim.gsplit(vim.bo.filetype, ".", { plain = true }) do
      for _, filetype in ipairs(tbl[ft] and tbl[ft]() or { ft }) do
        table.insert(filetypes, filetype)
      end
    end
    return filetypes
  end,
}) --[[@as function]]
