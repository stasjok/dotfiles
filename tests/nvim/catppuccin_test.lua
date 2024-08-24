local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality
local not_errors = expect.no_error
local ok = expect.assertion

local child = Child.new()
local api = child.api
local cmd = child.cmd
local fn = child.fn
local lua = child.lua
local lua_func = child.lua_func

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["is compiled"] = function()
  -- Cache directory doesn't exist when catppuccin is pre-compiled
  local stdcache = fn.stdpath("cache") --[[@as string]]
  ok(
    fn.isdirectory(vim.fs.joinpath(stdcache, "catppuccin")) == 0,
    "Found catppuccin cache directory, expected no cache directory."
  )

  -- Instead of Vimscript files (uncompiled), there are Lua files in the colors directory
  for _, suffix in ipairs({ "", "-frappe", "-latte", "-macchiato", "-mocha" }) do
    local vim_color_name = vim.fs.joinpath("colors", "catppuccin" .. suffix .. ".vim")
    local lua_color_name = vim.fs.joinpath("colors", "catppuccin" .. suffix .. ".lua")
    ok(
      #api.nvim_get_runtime_file(vim_color_name, false) == 0,
      "Found uncompiled color file: " .. vim_color_name
    )
    ok(
      #api.nvim_get_runtime_file(lua_color_name, false) == 1,
      "Not found compiled color file: " .. lua_color_name
    )
  end
end

T["works"] = function()
  -- Help is available
  eq(fn.getcompletion("catppuccin.txt", "help"), { "catppuccin.txt" })

  -- Lua modules are available
  not_errors(lua, [[require("catppuccin")]])
  not_errors(lua, [[require("catppuccin.palettes")]])

  -- Colorschemes are loadable
  not_errors(cmd, "colorscheme catppuccin-latte")
  not_errors(cmd, "colorscheme catppuccin-frappe")
  not_errors(cmd, "colorscheme catppuccin-macchiato")
  not_errors(cmd, "colorscheme catppuccin-mocha")
end

-- Test enabled integrations
T["integrations"] = new_set({
  parametrize = {
    { "mini", "MiniSurround", { bg = "pink", fg = "surface1" } },
  },
  hooks = {
    pre_once = function()
      -- Reset colorscheme to macchiato flavour
      child.restart()
      cmd.colorscheme("catppuccin-macchiato")
    end,
  },
}, {
  test = function(_, group, expectation)
    local hl = lua_func(function(name)
      -- Get macchiato palette and convert it into a table where
      -- the keys are integer representations of palette colors
      -- and the values are the corresponding palette names
      local palette = vim
        .iter(require("catppuccin.palettes.macchiato"))
        :fold({}, function(acc, n, hex)
          -- Convert #HEX to integer
          local num = tonumber(hex:sub(2), 16)
          acc[num] = n
          return acc
        end)

      -- Resolve colors to palette names
      return vim
        .iter(vim.api.nvim_get_hl(0, { name = name, create = false }))
        :fold({}, function(acc, k, v)
          acc[k] = palette[v] or v
          return acc
        end)
    end, group)

    eq(hl, expectation)
  end,
})

return T
