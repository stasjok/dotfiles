local expect = require("test.expect")
local Child = require("test.Child")
local new_set = MiniTest.new_set

local eq = expect.equality
local ok = expect.assertion
local matches = expect.matching
local errors = expect.error

local child = Child.new({ minimal = true })

--
-- Test against both child and self
--

local targets = {
  self = vim,
  child = child,
}

T = new_set({
  parametrize = {
    { "self" },
    { "child" },
  },
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

-- Ensure there are no any messages
T["messages"] = function(type)
  local target = targets[type]

  local messages = target.api.nvim_exec2("messages", { output = true }).output
  ok(messages == "", messages)
end

T["runtime paths"] = function(type)
  local target = targets[type]

  -- Runtimepath
  local rtp = vim.split(target.o.runtimepath, ",", { plain = true })
  eq(rtp[1], "tests/nvim/runtime") -- Test runtime
  matches(rtp[2], "nvim%-config$") -- home config
  matches(rtp[3], "vim-pack-dir", 1, true) -- Plugins
  eq(rtp[4], target.env.VIMRUNTIME) -- Nvim runtime
  matches(rtp[5], "nvim-config/after", 1, true) -- home config after directory
  eq(#rtp, 5) -- No more paths

  -- Packdir
  local packpath = vim.split(target.o.packpath, ",", { plain = true })
  matches(packpath[1], "vim-pack-dir", 1, true) -- Plugins
  eq(packpath[2], target.env.VIMRUNTIME) -- Nvim runtime
  eq(#packpath, 2) -- No more paths
end

-- Test that minimal Nvim is actually minimal
T["minimal"] = function(type)
  local target = targets[type]

  -- Everything is disabled
  errors(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypeplugin" })
  errors(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypeindent" })
  -- 'syntaxset' group is always defined, so check that it's empty
  eq(#target.api.nvim_get_autocmds({ group = "syntaxset" }), 0)
  errors(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "Syntax" })
  errors(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypedetect" })
  expect.is_false(target.go.loadplugins, "loadplugins option is enabled")

  -- No swap file, no shada
  eq(target.go.updatecount, 0)
  eq(target.go.shadafile, "NONE")
end

return T
