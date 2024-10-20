local Child = require("test.Child")
local expect = MiniTest.expect
local new_set = MiniTest.new_set

local eq = expect.equality

local child = Child.new()
local api = child.api
local cmd = child.cmd
local type_keys = child.type_keys

---@enum
local keys = {
  switch_left = "<M-h>",
  switch_down = "<M-j>",
  switch_up = "<M-k>",
  switch_right = "<M-l>",
  resize_left = "<M-H>",
  resize_down = "<M-J>",
  resize_up = "<M-K>",
  resize_right = "<M-L>",
}

local resize_amount = 2

local T = new_set({
  hooks = {
    pre_case = function()
      -- Avoid tmux auto-detection by smart-splits.nvim
      vim.env.TERM_PROGRAM = ""

      child.setup()
    end,
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

--- Get current window dimensions
---@return {width: integer, height: integer}
local function get_win_dimensions()
  local win = api.nvim_get_current_win()
  return {
    width = api.nvim_win_get_width(win),
    height = api.nvim_win_get_height(win),
  }
end

--- Validate window resize
---@param resize_key string Keys for resizing
---@param expected_resize {width: integer, height: integer} Expected resize amounts
---@param mode string Expected mode
local function validate_resize(resize_key, expected_resize, mode)
  eq(get_mode(), mode)
  local initial_dimensions = get_win_dimensions()
  type_keys(resize_key)
  local new_dimensions = get_win_dimensions()
  eq(new_dimensions, {
    width = initial_dimensions.width + expected_resize.width,
    height = initial_dimensions.height + expected_resize.height,
  })
  eq(get_mode(), mode)
end

--- Validate mapping
---@param pre_command string Vimscript command to execute before typing keys
---@param initial_mode string Expected initial mode before switching windows
---@param resize_keys table<string, {width: integer, height: integer}> Keys for resizing and expected resize amounts
---@param switch_key string Keys for switching
---@param expected_win integer Expected current window number after switching windows
---@param expected_mode string Expected mode after switching windows
local function validate_mapping(
  pre_command,
  initial_mode,
  resize_keys,
  switch_key,
  expected_win,
  expected_mode
)
  cmd(pre_command)
  -- Switching to terminal mode isn't instant for some reason, so wait a bit
  vim.wait(100, function()
    return get_mode() == initial_mode
  end, 1)
  eq(get_mode(), initial_mode)

  for resize_key, expected_resize in pairs(resize_keys) do
    validate_resize(resize_key, expected_resize, initial_mode)
  end

  type_keys(switch_key)
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

  -- On 1
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = -resize_amount, height = 0 },
    [keys.resize_right] = { width = resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = -resize_amount },
    [keys.resize_down] = { width = 0, height = resize_amount },
  }, keys.switch_right, 2, "n")

  -- On 2
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = resize_amount, height = 0 },
    [keys.resize_right] = { width = -resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = -resize_amount },
    [keys.resize_down] = { width = 0, height = resize_amount },
  }, keys.switch_down, 4, "n")

  -- On 4
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = resize_amount, height = 0 },
    [keys.resize_right] = { width = -resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = resize_amount },
    [keys.resize_down] = { width = 0, height = -resize_amount },
  }, keys.switch_left, 3, "n")

  -- On 3
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = -resize_amount, height = 0 },
    [keys.resize_right] = { width = resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = resize_amount },
    [keys.resize_down] = { width = 0, height = -resize_amount },
  }, keys.switch_up, 1, "n")
end

T["multiple windows"]["wraps around"] = function(mode, pre_command)
  eq(get_current_win_number(), 1)

  -- On 1
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = -resize_amount, height = 0 },
    [keys.resize_right] = { width = resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = -resize_amount },
    [keys.resize_down] = { width = 0, height = resize_amount },
  }, keys.switch_left, 2, "n")

  -- On 2
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = resize_amount, height = 0 },
    [keys.resize_right] = { width = -resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = -resize_amount },
    [keys.resize_down] = { width = 0, height = resize_amount },
  }, keys.switch_up, 4, "n")

  -- On 4
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = resize_amount, height = 0 },
    [keys.resize_right] = { width = -resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = resize_amount },
    [keys.resize_down] = { width = 0, height = -resize_amount },
  }, keys.switch_right, 3, "n")

  -- On 3
  validate_mapping(pre_command, mode, {
    [keys.resize_left] = { width = -resize_amount, height = 0 },
    [keys.resize_right] = { width = resize_amount, height = 0 },
    [keys.resize_up] = { width = 0, height = resize_amount },
    [keys.resize_down] = { width = 0, height = -resize_amount },
  }, keys.switch_down, 1, "n")
end

T["single window"] = new_set()

T["single window"]["switching"] = function(mode, pre_command)
  local initial_win = get_current_win_number()

  -- TODO: Current mappings are always returning to normal mode
  validate_mapping(pre_command, mode, {}, keys.switch_left, initial_win, "n")
  validate_mapping(pre_command, mode, {}, keys.switch_down, initial_win, "n")
  validate_mapping(pre_command, mode, {}, keys.switch_up, initial_win, "n")
  validate_mapping(pre_command, mode, {}, keys.switch_right, initial_win, "n")
end

T["single window"]["resizing"] = function(mode, pre_command)
  cmd(pre_command)

  validate_resize(keys.resize_left, { width = 0, height = 0 }, mode)
  validate_resize(keys.resize_right, { width = 0, height = 0 }, mode)
  validate_resize(keys.resize_down, { width = 0, height = 0 }, mode)
  -- Resize up reduces height of the window and increases 'cmdheight'
  validate_resize(keys.resize_up, { width = 0, height = -resize_amount }, mode)
  validate_resize(keys.resize_down, { width = 0, height = resize_amount }, mode)
end
return T
