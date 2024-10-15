local Child = require("test.Child")
local helpers = require("test.helpers")
local expect = MiniTest.expect
local new_set = MiniTest.new_set
local dedent = helpers.dedent

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local api = child.api
local bo = child.bo
local ensure_normal_mode = child.ensure_normal_mode
local get_screenshot = child.get_screenshot
local lua_func = child.lua_func
local set_cursor = child.set_cursor
local set_lines = child.set_lines
local set_size = child.set_size
local type_keys = child.type_keys

local T = new_set({
  hooks = {
    pre_case = function()
      child.setup()
      child.disable_lsp_autostart()
    end,
    post_once = child.stop,
  },
})

local k = {
  init = "<CR>",
  node_inc = "<CR>",
  scope_inc = "<C-J>", -- <C-Enter>
  node_dec = "<M-CR>",
}

local function validate(selected_text)
  -- Visual mode is active
  eq(api.nvim_get_mode().mode, "v")
  eq(
    lua_func(function()
      return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
    end),
    selected_text
  )
end

T["works"] = new_set({
  hooks = {
    pre_case = function()
      bo.filetype = "lua"
      set_lines(dedent([[
        local var = 123
      ]]))
      set_cursor(1, 7) -- On 'var'

      -- Activate initial selection
      type_keys(k.init)
      validate({ "var" })
    end,
  },
}, {
  node_incremental = function()
    -- Increment
    type_keys(k.node_inc)
    validate({ "var = 123" })

    -- Increment more
    type_keys(k.node_inc)
    validate({ "local var = 123" })

    -- Decrement selection
    type_keys(k.node_dec)
    validate({ "var = 123" })

    -- Decrement more
    type_keys(k.node_dec)
    validate({ "var" })
  end,

  scope_incremental = function()
    -- Scope increment
    type_keys(k.scope_inc)
    validate({ "local var = 123" })

    -- Decrement
    type_keys(k.node_dec)
    validate({ "var" })
  end,
})

-- To execute command in |command-line-window| <CR> is used
-- nvim-treesitter's incremental_selection mustn't map it in cmdwin
T["doesn't interfere with command line window"] = function()
  set_size(40, 12)
  -- Activate command-line window and type command to edit makeprg option
  type_keys("q:", "cc", "setlocal makeprg=test")
  -- Activate command from normal mode
  ensure_normal_mode()
  type_keys("<CR>")
  -- Validate that command is executed
  ok(
    bo.makeprg == "test",
    "expected command in |command-line-window| to be executed. It's possible that <CR> is remapped to something.\n"
      .. "Screenshot:\n"
      .. tostring(get_screenshot())
  )
end

return T
