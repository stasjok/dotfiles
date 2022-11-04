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

  local function filter_lines(keyword)
    return function(s)
      return string.find(s, "^[%s-]+" .. keyword)
    end
  end

  local is_nix = vim.env.name == "nix-profile-test"
  local ignore = {
    "`tree-sitter` executable not found",
    "No clipboard tool found",
    -- It's expected when I run tests inside neovim terminal
    "$TERM differs from the tmux `default-terminal` setting",
  }
  local ignore_in_nix = {
    -- TODO: find out why LOCALE_ARCHIVE doesn't work in nix build
    -- even if I explicitly specify it in environment variable
    "Locale does not support UTF-8",
  }
  local function filter_errors(s)
    for _, match in ipairs(ignore) do
      if string.find(s, match, 8, true) then
        return false
      end
    end
    if is_nix then
      for _, match in ipairs(ignore_in_nix) do
        if string.find(s, match, 8, true) then
          return false
        end
      end
    end
    return true
  end

  local lines = child.api.nvim_buf_get_lines(0, 0, -1, true)
  local errors = vim.tbl_filter(filter_lines("ERROR"), lines)
  -- Ignore some of the errors
  errors = vim.tbl_filter(filter_errors, errors)
  eq(errors, {})
  local warnings = vim.tbl_filter(filter_lines("WARNING"), lines)
  -- Ignore some of the warnings
  warnings = vim.tbl_filter(filter_errors, warnings)
  eq(warnings, {})
end

return T
