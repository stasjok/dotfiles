local expect = MiniTest.expect
local Child = require("test.Child")
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion

local child = Child.new()
local cmd = child.cmd
local cmd_capture = child.cmd_capture
local lua = child.lua
local lua_get = child.lua_get

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

-- Ensure there are no any messages
T["messages"] = function()
  local messages = cmd_capture("messages")
  ok(messages == "", messages)
end

T["checkhealth"] = function()
  -- List of ignored messages
  local ignored = {
    "Missing user config file",
    "`tree-sitter` executable not found",
    "`cc` executable not found",
    "No clipboard tool found",
    -- It's expected when running tests inside neovim terminal
    "$TERM differs from the tmux `default-terminal` setting",
    -- I'm testing internal watcher
    "libuv-watchdirs has known performance issues",
    -- diffview.nvim
    "`hg_cmd` is not executable",
  }

  -- Mock Nvim health functions (:h health-functions) in order to collect warnings and errors.
  lua([[
    _G.healthchecks = {}

    -- Remember last report name
    local last_name = "unknown"
    local health_start = vim.health.start
    vim.health.start = function(name)
      last_name = name
      health_start(name)
    end

    -- Collect warnings
    local health_warn = vim.health.warn
    vim.health.warn = function(msg, ...)
      table.insert(_G.healthchecks, string.format("WARNING(%s): %s", last_name, msg))
      health_warn(msg, ...)
    end

    -- Collect errors
    local health_error = vim.health.error
    vim.health.error = function(msg, ...)
      table.insert(_G.healthchecks, string.format("ERROR(%s): %s", last_name, msg))
      health_error(msg, ...)
    end
  ]])

  -- Run :checkhealth
  cmd.checkhealth()

  -- Get collected healthchecks
  local healthchecks = lua_get("_G.healthchecks")

  -- Skip ignored messages
  healthchecks = vim.tbl_filter(function(s)
    for _, match in ipairs(ignored) do
      if string.find(s, match, 1, true) then
        return false
      end
    end
    return true
  end, healthchecks)

  eq(healthchecks, {})
end

return T
