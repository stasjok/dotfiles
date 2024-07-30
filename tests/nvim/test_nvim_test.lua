local new_set = MiniTest.new_set
local helpers = require("test.helpers")
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
  child.lua([[MiniTest.run_file(...)]], { "tests/nvim/nvim_test_spec.lua" })
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

T["child_methods"] = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["child_methods"]["child.get_lines()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "a", "b", "c", "d" })
    end,
  },
})

T["child_methods"]["child.get_lines()"]["works"] = new_set({
  parametrize = {
    -- join option
    { { "a", "b", "c", "d" } },
    { { "a", "b", "c", "d" }, { join = false } },
    { "a\nb\nc\nd", { join = true } },
    -- line-range
    { { "b", "c" }, { start = 1, finish = 3 } },
    -- strict
    { { "a", "b", "c", "d" }, { finish = 10, strict = false } },
  },
}, {
  test = function(expectation, args)
    eq(child.get_lines(args), expectation)
  end,
})

T["child_methods"]["child.get_lines()"]["strict"] = function()
  expect.error(child.get_lines, "Index out of bounds", { finish = 10 })
end

T["child_methods"]["child.get_lines()"]["buffer"] = function()
  local buf = child.api.nvim_create_buf(false, true)
  child.api.nvim_buf_set_lines(buf, 0, -1, true, { "1", "2" })
  eq(child.get_lines({ buf = buf }), { "1", "2" })
  eq(child.get_lines({ buf = 0 }), { "a", "b", "c", "d" })
end

T["child_methods"]["child.set_lines()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "a", "b" })
    end,
  },
})

T["child_methods"]["child.set_lines()"]["works"] = new_set({
  parametrize = {
    -- lines
    { { "line1", "line2" }, { "line1", "line2" } },
    { { "line1", "line2" }, "line1\nline2" },
    -- line-range
    { { "a", "line", "b" }, "line", { start = 1, finish = 1 } },
    -- strict
    { { "a", "line" }, "line", { start = 1, finish = 10, strict = false } },
  },
}, {
  test = function(expectation, lines, args)
    child.set_lines(lines, args)
    eq(child.api.nvim_buf_get_lines(0, 0, -1, true), expectation)
  end,
})

T["child_methods"]["child.set_lines()"]["strict"] = function()
  expect.error(child.set_lines, "Index out of bounds", "line", { finish = 10 })
end

T["child_methods"]["child.set_lines()"]["buffer"] = function()
  local buf = child.api.nvim_create_buf(false, true)
  child.set_lines({ "1", "2" }, { buf = buf })
  eq(child.api.nvim_buf_get_lines(buf, 0, -1, true), { "1", "2" })
  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "a", "b" })
end

T["child_methods"]["child.get_cursor()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "aaa", "bbb", "ccc" })
    end,
  },
})

T["child_methods"]["child.get_cursor()"]["works"] = new_set({
  parametrize = {
    { 1, 0 },
    { 2, 2 },
  },
}, {
  test = function(row, col)
    child.api.nvim_win_set_cursor(0, { row, col })
    eq({ child.get_cursor() }, { row, col })
  end,
})

T["child_methods"]["child.get_cursor()"]["window"] = function()
  child.cmd("split")
  for index, win in ipairs(child.api.nvim_list_wins()) do
    child.api.nvim_win_set_cursor(win, { index, index })
    eq({ child.get_cursor(win) }, { index, index })
  end
end

T["child_methods"]["child.set_cursor()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "aaa", "bbb", "ccc" })
    end,
  },
})

T["child_methods"]["child.set_cursor()"]["works"] = new_set({
  parametrize = {
    { 1, 0 },
    { 2, 2 },
  },
}, {
  test = function(row, col)
    child.set_cursor(row, col)
    eq(child.api.nvim_win_get_cursor(0), { row, col })
  end,
})

T["child_methods"]["child.set_cursor()"]["window"] = function()
  child.cmd("split")
  for index, win in ipairs(child.api.nvim_list_wins()) do
    child.set_cursor(index, index, win)
    eq(child.api.nvim_win_get_cursor(win), { index, index })
  end
end

T["child_methods"]["child.get_size()"] = function()
  child.lua("vim.opt.columns = 20")
  child.lua("vim.opt.lines = 10")
  eq({ child.get_size() }, { 20, 10 })
end

T["child_methods"]["child.set_size()"] = function()
  child.set_size(30, 20)
  eq({ child.o.columns, child.o.lines }, { 30, 20 })
end

return T
