local expect = require("test.expect")
local Child = require("test.Child")
local new_set = MiniTest.new_set
local eq = expect.equality

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

T["runtime paths"] = function(type)
  local target = targets[type]

  -- Runtimepath
  local rtp = vim.split(target.o.runtimepath, ",", { plain = true })
  eq(rtp[1], "tests/nvim/runtime") -- Test runtime
  eq(rtp[2], target.fn.stdpath("config")) -- XDG_CONFIG_HOME
  expect.match(rtp[3], "vim-pack-dir", 1, true) -- Plugins
  eq(rtp[4], target.env.VIMRUNTIME) -- Nvim runtime
  eq(rtp[5], target.fn.stdpath("config") .. "/after") -- XDG_CONFIG_HOME after directory
  eq(#rtp, 5) -- No more paths

  -- Packdir
  local packpath = vim.split(target.o.packpath, ",", { plain = true })
  expect.match(packpath[1], "vim-pack-dir", 1, true) -- Plugins
  eq(packpath[2], target.env.VIMRUNTIME) -- Nvim runtime
  eq(#packpath, 2) -- No more paths
end

-- Test that minimal Nvim is actually minimal
T["minimal"] = function(type)
  local target = targets[type]

  -- Everything is disabled
  expect.error(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypeplugin" })
  expect.error(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypeindent" })
  -- 'syntaxset' group is always defined, so check that it's empty
  eq(#target.api.nvim_get_autocmds({ group = "syntaxset" }), 0)
  expect.error(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "Syntax" })
  expect.error(target.api.nvim_get_autocmds, "Invalid 'group'", { group = "filetypedetect" })
  expect.is_false(target.go.loadplugins, "loadplugins option is enabled")

  -- No swap file, no shada
  eq(target.go.updatecount, 0)
  eq(target.go.shadafile, "NONE")
end

return T
