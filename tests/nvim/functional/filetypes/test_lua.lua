local helpers = dofile("tests/nvim/minitest_helpers.lua")
local new_set, new_child = MiniTest.new_set, helpers.new_child
local eq, expect = MiniTest.expect.equality, helpers.expect

local child = new_child()

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
})

T["dotfiles"] = function()
  ---Get a property from child's sumneko_lua client
  ---@param key string A property from child object
  ---@param filter? table<string, any> A filter `vim.lsp.get_active_clients()` function
  ---@return any
  local function lsp_client_get(key, filter)
    filter = vim.tbl_extend("force", { name = "sumneko_lua" }, filter or {})
    return child.lua_get("vim.lsp.get_active_clients(...)[1]." .. key, { filter })
  end

  child.cmd("cd tests/data/dotfiles")

  -- Set `b:diagnostics` variable to `true` when diagnostics are published
  child.lua('vim.lsp.handlers["textDocument/publishDiagnostics"] = loadstring(...)', {
    string.dump(function(...)
      vim.lsp.diagnostic.on_publish_diagnostics(...)
      local bufnr = vim.uri_to_bufnr(select(2, ...).uri)
      vim.b[bufnr].diagnostics = true
    end),
  })

  ---Wait until `b:diagnostics` variable is truthy
  ---@param bufnr integer A buffer handler
  ---@param timeout? integer Maximum waiting time
  local function wait_diagnostics(bufnr, timeout)
    if
      not child.lua_get(
        string.format(
          "vim.wait(%i, function() return vim.b[%i].diagnostics end, 50)",
          timeout or 10000,
          bufnr
        )
      )
    then
      error("LSP client didn't publish diagnostics in time.")
    end
  end

  -- Buffers
  child.cmd("edit nvim/init.lua")
  local init_buf = child.lua_get("vim.api.nvim_get_current_buf()")
  wait_diagnostics(init_buf)
  child.cmd("edit nvim/lua/utils.lua")
  local utils_buf = child.lua_get("vim.api.nvim_get_current_buf()")
  wait_diagnostics(utils_buf)
  child.cmd("edit tests/nvim_spec.lua")
  local spec_buf = child.lua_get("vim.api.nvim_get_current_buf()")
  wait_diagnostics(spec_buf)
  child.cmd("edit tests/test_nvim.lua")
  local test_buf = child.lua_get("vim.api.nvim_get_current_buf()")
  wait_diagnostics(test_buf)

  -- Make sure nvim and tests share the same lsp client
  expect.no_equality(utils_buf, spec_buf)
  eq(lsp_client_get("id", { bufnr = init_buf }), lsp_client_get("id", { bufnr = utils_buf }))
  eq(lsp_client_get("id", { bufnr = init_buf }), lsp_client_get("id", { bufnr = spec_buf }))
  eq(lsp_client_get("id", { bufnr = init_buf }), lsp_client_get("id", { bufnr = test_buf }))
  eq(lsp_client_get("config.root_dir"), vim.loop.fs_realpath("tests/data/dotfiles"))

  -- Make sure globals are recognized
  local diagnostic_namespace =
    child.lua_get("vim.lsp.diagnostic.get_namespace(...)", { lsp_client_get("id") })
  ---Get diagnostics from sumneko_lua for buffer
  ---@param bufnr integer A buffer handler
  ---@return table
  local function get_diagnostics(bufnr)
    local diagnostics =
      child.lua_get("vim.diagnostic.get(...)", { bufnr, { namespace = diagnostic_namespace } })
    return vim.tbl_filter(function(v)
      return not v.message:find("_NOT_EXISTENT", 1, true)
    end, diagnostics)
  end
  eq({}, get_diagnostics(init_buf))
  eq({}, get_diagnostics(spec_buf))
  eq({}, get_diagnostics(test_buf))
end

return T
