local new_set = MiniTest.new_set
local helpers = dofile("tests/nvim/helpers_minitest.lua")
local expect, eq = helpers.expect, MiniTest.expect.equality

local child = helpers.new_child()

local T = new_set()

T["helpers"] = new_set()

T["helpers"]["expect.match()"] = function()
  local function error_pattern(s)
    return vim.pesc(string.format("Pattern: %s\n", s))
  end
  -- Works
  eq(expect.match("test", "test"), true)
  expect.error(expect.match, error_pattern("no_match"), "test", "no_match")
  -- Works with plain pattern
  expect.error(expect.match, error_pattern("test-test"), "test-test", "test-test")
  eq(expect.match("test-test", "test-test", 1, true), true)
  -- Pattern text
  expect.error(expect.match, error_pattern("test, 2"), "test", "test", 2)
  expect.error(expect.match, error_pattern("test, 2, true"), "test", "test", 2, true)
  expect.error(expect.match, error_pattern("test, 2, false"), "test", "test", 2, false)
  expect.error(expect.match, error_pattern("no_match, nil, true"), "test", "no_match", nil, true)
  expect.error(expect.match, error_pattern("no_match"), "test", "no_match", nil, nil)
  -- no_match()
  eq(expect.no_match("test", "no_match"), true)
  expect.error(expect.no_match, error_pattern("test"), "test", "test")
  eq(expect.no_match("test-test", "test%-test", nil, true), true)
end

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
  eq(rtp[1], vim.fn.fnamemodify("nvim", ":p:h"))
  expect.match(rtp[2], "vim%-pack%-dir$")
  expect.match(rtp[3], "vim-pack-dir/pack/*/start/*", 1, true)
  eq(rtp[4], child.env.VIMRUNTIME)
  expect.match(rtp[#rtp - 1], "vim-pack-dir/pack/*/start/*/after", 1, true)
  eq(rtp[#rtp], vim.fn.fnamemodify("nvim/after", ":p:h"))
  local config_home = vim.fs.normalize("~/.config/nvim")
  local data_home = vim.fs.normalize("~/.local/state/nvim")
  for _, dir in ipairs(rtp) do
    expect.no_equality(dir, config_home)
    expect.no_equality(dir, data_home)
  end
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

T["child"]["stdpath"] = function()
  eq(child.fn.stdpath("data"), "nvim")
  eq(child.fn.stdpath("state"), vim.fn.fnamemodify("tests/nvim/state/nvim", ":p:h"))
  eq(child.fn.stdpath("log"), vim.fn.fnamemodify("tests/nvim/state/nvim", ":p:h"))
  eq(child.fn.stdpath("cache"), vim.fn.fnamemodify("tests/nvim/cache/nvim", ":p:h"))
  eq(child.fn.stdpath("config_dirs"), {})
  eq(child.fn.stdpath("data_dirs"), {})
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
  child.lua([[MiniTest.run_file(...)]], { "tests/nvim/integration/test_nvim_test.lua" })
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
