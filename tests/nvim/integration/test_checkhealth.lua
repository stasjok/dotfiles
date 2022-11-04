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

T["checkhealth"] = function()
  child.cmd("checkhealth")
  eq(child.bo.filetype, "checkhealth")

  local function filter(keyword)
    return function(s)
      return string.find(s, "^[%s-]+" .. keyword)
    end
  end
  local lines = child.api.nvim_buf_get_lines(0, 0, -1, true)
  local errors = vim.tbl_filter(filter("ERROR"), lines)
  eq(errors, {})
  local warnings = vim.tbl_filter(filter("WARNING"), lines)
  -- Ignore some of the warnings
  warnings = vim.tbl_filter(function(s)
    return string.find(s, "`tree-sitter` executable not found")
  end, warnings)
  eq(warnings, {})
end

return T
