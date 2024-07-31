local expect = require("test.expect")
local eq = expect.equality
local helpers = require("test.helpers")
local new_set = MiniTest.new_set

local child = helpers.new_child()

local T = new_set()

T["child"] = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["child"]["nvim"] = function()
  eq(child.is_running(), true)
  eq(child.is_blocked(), false)
end

T["child"]["runtimepath"] = function()
  local rtp = child.lua_get("vim.opt.runtimepath:get()")
  eq(rtp[1], vim.uv.fs_realpath(vim.fs.normalize("~/.config/nvim")))
  expect.match(rtp[2], "vim%-pack%-dir$")
  expect.match(rtp[3], "vim-pack-dir/pack/*/start/*", 1, true)
  eq(rtp[4], child.env.VIMRUNTIME)
  expect.match(rtp[#rtp - 1], "vim-pack-dir/pack/*/start/*/after", 1, true)
  eq(rtp[#rtp], vim.uv.fs_realpath(vim.fs.normalize("~/.config/nvim/after")))
end

T["child"]["packpath"] = function()
  local packpath = child.lua_get("vim.opt.packpath:get()")
  expect.match(packpath[1], "vim%-pack%-dir$")
  eq(packpath[2], child.env.VIMRUNTIME)
  eq(#packpath, 2)
end

T["child"]["VIMRUNTIME"] = function()
  expect.match(child.env.VIMRUNTIME, vim.fn.fnamemodify(child.v.progpath, ":h:h"), 1, true)
end

T["child"]["ftdetect"] = function()
  expect.no_error(child.api.nvim_get_autocmds, { group = "filetypedetect" })
end

T["child"]["options"] = function()
  eq(child.go.loadplugins, true)
  eq(child.go.updatecount, 0)
  eq(child.go.shadafile, "NONE")
end

---@diagnostic disable-next-line: redefined-local
local child = helpers.new_child({ minimal = true })

T["minimal_child"] = new_set({
  hooks = {
    pre_once = child.setup,
    post_once = child.stop,
  },
})

T["minimal_child"]["test_nvim_test.lua tests"] = function()
  child.lua([[require("mini.test").setup(...)]], {
    { execute = { reporter = { start = nil, update = nil, finish = nil } } },
  })
  -- Make sure tests never run before
  eq(child.lua_get("MiniTest.current.all_cases"), vim.NIL)
  -- Run tests
  child.lua([[MiniTest.run_file(...)]], { "tests/nvim/test_nvim2_test.lua" })
  -- Make sure tests are finished
  eq(child.lua_get("MiniTest.is_executing()"), false)
  -- Remove functions from list of cases
  child.lua([[for _, case in ipairs(MiniTest.current.all_cases) do case.test = nil end]])
  -- Get a list of failed tests
  local all_cases = child.lua_get("MiniTest.current.all_cases")
  all_cases = vim.tbl_filter(function(t)
    return t.exec.state ~= "Pass"
  end, all_cases)
  -- There should be no failed tests
  eq(all_cases, {})
end

return T
