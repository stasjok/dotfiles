local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local ok = expect.assertion

local child = Child.new()
local api = child.api

local T = new_set({ hooks = {
  pre_once = child.setup,
  post_once = child.stop,
} })

T["runtime paths"] = function()
  local runtime_path_number = #api.nvim_list_runtime_paths()
  ok(
    runtime_path_number < 10,
    string.format(
      "Number of runtime paths should be as small as possible. Expected < 10, got %s.",
      runtime_path_number
    )
  )
end

T["byte compiling"] = function()
  expect.no_error(child.lua_func, function()
    -- Test every lua file found in runtime
    for _, path in ipairs(vim.api.nvim_get_runtime_file("**/*.lua", true)) do
      local f = assert(io.open(path, "rb"))
      -- Read three bytes
      local data = assert(f:read(3)) --[[@as string]]
      local bytes = { data:byte(1, 3) }
      -- LuaJIT byte compiled files are beginning with: 1B 4C 4A (ESC L J)
      local expected = { 0x1b, string.byte("L"), string.byte("J") }
      assert(
        vim.deep_equal(expected, bytes),
        string.format(
          "File '%s' is not byte compiled. Expected %s, got %s.",
          path,
          vim.inspect(expected),
          vim.inspect(bytes)
        )
      )
      assert(f:close())
    end
  end)
end

return T
