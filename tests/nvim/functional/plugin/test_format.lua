local helpers = dofile("tests/nvim/minitest_helpers.lua")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq = MiniTest.expect.equality

local child = new_child()

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

local format_mapping = vim.api.nvim_replace_termcodes("<Space>F", true, false, true)
local tests = {
  lua = {
    ext = "lua",
    lsp_name = "null-ls",
    string = "local a=1",
    formatted_string = "local a = 1",
    formatting = true,
    range_formatting = false,
    on_save = true,
    extra_files = { "stylua.toml" },
  },
  nix = {
    string = "{}",
    formatted_string = "{ }",
    formatting = true,
    on_save = true,
  },
  yaml = {
    string = "a:  1",
    formatted_string = "a: 1",
    formatting = true,
  },
  python = {
    ext = "py",
    lsp_name = "null-ls",
    string = "a=1",
    formatted_string = "a = 1",
    formatting = true,
  },
  sh = {
    lsp_name = "null-ls",
    string = "echo  1",
    formatted_string = "echo 1",
    formatting = true,
    range_formatting = false,
    on_save = false,
  },
}

local function prepare_test_dir(ft, test)
  local tmp = vim.env.TMPDIR or "/tmp"
  local tmpdir = assert(vim.loop.fs_mkdtemp(tmp .. "/test_format.XXXXXX"))
  MiniTest.finally(function()
    vim.fn.delete(tmpdir, "rf")
  end)
  assert(vim.loop.fs_mkdir(tmpdir .. "/.git", 493))
  for _, file in ipairs(test.extra_files or {}) do
    local fd = assert(vim.loop.fs_open(tmpdir .. "/" .. file, "a", 420))
    assert(vim.loop.fs_close(fd))
  end
  child.api.nvim_cmd({ cmd = "cd", args = { tmpdir } }, {})
  child.api.nvim_cmd({ cmd = "edit", args = { "test." .. (test.ext or ft) } }, {})
  child.set_lines(test.string)
  repeat
    vim.loop.sleep(20)
    -- get_active_clients() is failing if calling too early
    local success, number_of_clients = pcall(
      child.lua_get,
      "#vim.lsp.get_active_clients(...)",
      { { bufnr = 0, name = test.lsp_name } }
    )
  until success and number_of_clients >= 1
  return tmpdir
end

for ft, test in pairs(tests) do
  T[ft] = new_set()

  T[ft]["normal-mode mapping"] = function()
    prepare_test_dir(ft, test)
    child.api.nvim_feedkeys(format_mapping, "tx", false)
    eq(child.get_lines(), { test.formatting and test.formatted_string or test.string })
  end

  T[ft]["visual-mode mapping"] = function()
    prepare_test_dir(ft, test)
    child.api.nvim_feedkeys("ggVG" .. format_mapping, "tx", false)
    eq(child.get_lines(), { test.range_formatting and test.formatted_string or test.string })
  end

  T[ft]["format on save"] = function()
    prepare_test_dir(ft, test)
    child.cmd("write")
    eq(child.get_lines(), { test.on_save and test.formatted_string or test.string })
  end
end

T["lua"]["format on save is disabled when there is no stylua.toml"] = function()
  local test = vim.deepcopy(tests.lua)
  test.extra_files = nil
  prepare_test_dir("lua", test)
  child.cmd("write")
  eq(child.get_lines(), { test.string })
end

return T
