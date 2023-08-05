local buf_delete = vim.api.nvim_buf_delete
local buf_is_valid = vim.api.nvim_buf_is_valid
local create_buf = vim.api.nvim_create_buf
local set_current_buf = vim.api.nvim_set_current_buf
local buf_line_count = vim.api.nvim_buf_line_count
local win_get_cursor = vim.api.nvim_win_get_cursor
local buf_get_mark = vim.api.nvim_buf_get_mark
local buf_get_lines = vim.api.nvim_buf_get_lines
local create_augroup = vim.api.nvim_create_augroup
local create_autocmd = vim.api.nvim_create_autocmd
local exec_autocmds = vim.api.nvim_exec_autocmds
local get_proc = vim.api.nvim_get_proc
local get_proc_children = vim.api.nvim_get_proc_children
local opt_local = vim.opt_local
local api = vim.api
local map = vim.keymap.set

local augroup = create_augroup("terminal", {})
create_autocmd("TermOpen", {
  group = augroup,
  pattern = "*",
  desc = "Set options for terminal window",
  callback = function()
    opt_local.number = false
    opt_local.relativenumber = false
    opt_local.signcolumn = "auto"
    opt_local.sidescrolloff = 0
  end,
})

local function on_exit()
  buf_delete(_G._my_terminal_buffer, { force = true })
  _G._my_terminal_buffer = nil
end

local function term_start_insert(args)
  local buf_end = false
  local line_count = buf_line_count(0)
  local current_line_number = win_get_cursor(0)[1]
  -- After changing buffer win_get_cursor always returns 1, 0
  if current_line_number == 1 then
    current_line_number = buf_get_mark(0, '"')[1]
  end
  if line_count == current_line_number then
    buf_end = true
  elseif line_count - current_line_number < 70 then
    -- New terminal buffer is filled with empty lines
    local lines = buf_get_lines(0, current_line_number, line_count, true)
    buf_end = true
    for _, line in ipairs(lines) do
      if line ~= "" then
        buf_end = false
        break
      end
    end
  end
  if buf_end then
    -- After switching buffers with telescope,
    -- first telescope floating window is closed, then BufEnter event is fired
    -- and after that buffer is immediately switched in current window.
    -- If we go to insert mode before buffer is changed, we'll get insert mode
    -- also in a target buffer. As a workaround delay going to insert mode.
    vim.schedule(function()
      if api.nvim_get_current_buf() == args.buf then
        api.nvim_feedkeys("i", "", false)
      end
    end)
  end
end

local function terminal_open()
  if _G._my_terminal_buffer == nil or not buf_is_valid(_G._my_terminal_buffer) then
    _G._my_terminal_buffer = create_buf(true, false)
    create_autocmd("BufEnter", {
      buffer = _G._my_terminal_buffer,
      callback = term_start_insert,
    })
    set_current_buf(_G._my_terminal_buffer)
    vim.fn.termopen("fish", {
      on_exit = on_exit,
    })
  else
    set_current_buf(_G._my_terminal_buffer)
  end
end

local procs_which_uses_esc = {
  nvim = true,
  vim = true,
  fzf = true,
}

local function is_proc_uses_esc(pid)
  if procs_which_uses_esc[get_proc(pid).name] then
    return true
  end
  for _, child_pid in ipairs(get_proc_children(pid)) do
    if is_proc_uses_esc(child_pid) then
      return true
    end
  end
  return false
end

local function terminal_esc()
  return is_proc_uses_esc(vim.b.terminal_job_pid) and "<Esc>" or "<C-\\><C-N>"
end

map("n", "<Leader>t", terminal_open)
map("t", "<Esc>", terminal_esc, { expr = true })
map("t", "<C-\\><Esc>", "<Esc>")
map("t", "<M-PageUp>", "<C-\\><C-N><PageUp>")

create_autocmd("VimEnter", {
  desc = "Open terminal automatically on startup",
  once = true,
  callback = function()
    if vim.o.columns >= 200 and api.nvim_buf_get_name(0) == "" then
      vim.cmd.vsplit()
      vim.cmd.wincmd("l")
      terminal_open()
      exec_autocmds("TermOpen", {
        group = augroup,
        buffer = 0,
      })
      vim.cmd.wincmd("h")
    end
  end,
})
