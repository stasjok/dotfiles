local expect = require("test.expect")
local Child = require("test.child")
local new_set = MiniTest.new_set
local eq = expect.equality

local child = Child.new({ minimal = true })

T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

--
-- Child methods
--

T["child.get_lines()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "a", "b", "c", "d" })
    end,
  },
})

T["child.get_lines()"]["works"] = new_set({
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

T["child.get_lines()"]["strict"] = function()
  expect.error(child.get_lines, "Index out of bounds", { finish = 10 })
end

T["child.get_lines()"]["buffer"] = function()
  local buf = child.api.nvim_create_buf(false, true)
  child.api.nvim_buf_set_lines(buf, 0, -1, true, { "1", "2" })
  eq(child.get_lines({ buf = buf }), { "1", "2" })
  eq(child.get_lines({ buf = 0 }), { "a", "b", "c", "d" })
end

T["child.set_lines()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "a", "b" })
    end,
  },
})

T["child.set_lines()"]["works"] = new_set({
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

T["child.set_lines()"]["strict"] = function()
  expect.error(child.set_lines, "Index out of bounds", "line", { finish = 10 })
end

T["child.set_lines()"]["buffer"] = function()
  local buf = child.api.nvim_create_buf(false, true)
  child.set_lines({ "1", "2" }, { buf = buf })
  eq(child.api.nvim_buf_get_lines(buf, 0, -1, true), { "1", "2" })
  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "a", "b" })
end

T["child.get_cursor()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "aaa", "bbb", "ccc" })
    end,
  },
})

T["child.get_cursor()"]["works"] = new_set({
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

T["child.get_cursor()"]["window"] = function()
  child.cmd("split")
  for index, win in ipairs(child.api.nvim_list_wins()) do
    child.api.nvim_win_set_cursor(win, { index, index })
    eq({ child.get_cursor(win) }, { index, index })
  end
end

T["child.set_cursor()"] = new_set({
  hooks = {
    pre_case = function()
      child.api.nvim_buf_set_lines(0, 0, -1, true, { "aaa", "bbb", "ccc" })
    end,
  },
})

T["child.set_cursor()"]["works"] = new_set({
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

T["child.set_cursor()"]["window"] = function()
  child.cmd("split")
  for index, win in ipairs(child.api.nvim_list_wins()) do
    child.set_cursor(index, index, win)
    eq(child.api.nvim_win_get_cursor(win), { index, index })
  end
end

T["child.get_size()"] = function()
  child.lua("vim.opt.columns = 20")
  child.lua("vim.opt.lines = 10")
  eq({ child.get_size() }, { 20, 10 })
end

T["child.set_size()"] = function()
  child.set_size(30, 20)
  eq({ child.o.columns, child.o.lines }, { 30, 20 })
end

return T
