local helpers = require("test.helpers")
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

  local ignore = {
    "`tree-sitter` executable not found",
    "`cc` executable not found",
    "No clipboard tool found",
    -- $MYVIMRC is not set when there is -u arg. https://github.com/neovim/neovim/issues/17602
    "Missing user config file",
    -- It's expected when running tests inside neovim terminal
    "$TERM differs from the tmux `default-terminal` setting",
    -- Perl is enabled but doesn't work
    "No usable perl executable found",
    '"Neovim::Ext" cpan module is not installed',
    -- I'm testing internal watcher
    "libuv-watchdirs has known performance issues",
    -- diffview.nvim
    "`hg_cmd` is not executable",
  }
  local function filter_errors(s)
    for _, match in ipairs(ignore) do
      if string.find(s, match, 8, true) then
        return false
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
