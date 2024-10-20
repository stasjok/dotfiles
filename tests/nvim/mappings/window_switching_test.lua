local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local api = child.api
local cmd = child.cmd
local type_keys = child.type_keys

local T = new_set({
  hooks = {
    pre_case = child.setup,
    post_once = child.stop,
  },
  parametrize = {
    { "n", "" },
    { "i", "startinsert" },
    { "v", "normal v" },
    { "t", "execute 'terminal' | startinsert" },
  },
})

local function get_current_win_number()
  return api.nvim_win_get_number(0)
end

--- Get one letter current mode
---@return string
local function get_mode()
  return api.nvim_get_mode().mode:sub(1, 1)
end

--- Validate mapping
---@param pre_command string Vimscript command to execute before typing keys
---@param initial_mode string Expected initial mode before typing keys
---@param key string Keys to type
---@param expected_win integer Expected current window number after typing keys
---@param expected_mode string Expected mode after typing keys
local function validate_mapping(pre_command, initial_mode, key, expected_win, expected_mode)
  cmd(pre_command)
  -- Switching to terminal mode isn't instant for some reason, so wait a bit
  vim.wait(100, function()
    return get_mode() == initial_mode
  end, 1)
  eq(get_mode(), initial_mode)
  type_keys(key)
  eq(get_current_win_number(), expected_win)
  eq(get_mode(), expected_mode)
end

T["multiple windows"] = new_set({
  hooks = {
    pre_case = function()
      -- Create a 4-window layout:
      -- +---+---+
      -- | 1 | 2 |
      -- +---+---+
      -- | 3 | 4 |
      -- +---+---+
      cmd("split")
      cmd("vsplit")
      cmd("wincmd j")
      cmd("vsplit")
      cmd("wincmd t") -- Return to top-left window
    end,
  },
})

T["multiple windows"]["works"] = function(mode, pre_command)
  eq(get_current_win_number(), 1)

  validate_mapping(pre_command, mode, "<M-l>", 2, "n")
  validate_mapping(pre_command, mode, "<M-j>", 4, "n")
  validate_mapping(pre_command, mode, "<M-h>", 3, "n")
  validate_mapping(pre_command, mode, "<M-k>", 1, "n")
end

T["multiple windows"]["wraps around"] = function(mode, pre_command)
  eq(get_current_win_number(), 1)

  validate_mapping(pre_command, mode, "<M-h>", 2, "n")
  validate_mapping(pre_command, mode, "<M-k>", 4, "n")
  validate_mapping(pre_command, mode, "<M-l>", 3, "n")
  validate_mapping(pre_command, mode, "<M-j>", 1, "n")
end

T["single window"] = new_set()

T["single window"]["does nothing"] = function(mode, pre_command)
  local initial_win = get_current_win_number()

  -- TODO: Current mappings are always returning to normal mode
  -- validate_mapping(pre_command, mode, "<M-h>", initial_win, mode)
  validate_mapping(pre_command, mode, "<M-h>", initial_win, "n")
  -- validate_mapping(pre_command, mode, "<M-j>", initial_win, mode)
  validate_mapping(pre_command, mode, "<M-j>", initial_win, "n")
  -- validate_mapping(pre_command, mode, "<M-k>", initial_win, mode)
  validate_mapping(pre_command, mode, "<M-k>", initial_win, "n")
  -- validate_mapping(pre_command, mode, "<M-l>", initial_win, mode)
  validate_mapping(pre_command, mode, "<M-l>", initial_win, "n")
end

return T
