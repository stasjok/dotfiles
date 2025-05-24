local vim = vim
local api = vim.api
local wo = vim.wo
local cmd = vim.cmd
local map = vim.keymap.set

local terminal_buffer = nil
local augroup = api.nvim_create_augroup("terminal", {})

api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  pattern = "*",
  desc = "Set options for terminal window",
  callback = function()
    wo[0][0].number = false
    wo[0][0].list = false
    wo[0][0].relativenumber = false
    wo[0][0].signcolumn = "auto"
    wo.scrolloff = 0
    wo.sidescrolloff = 0
  end,
})

local function on_exit()
  if terminal_buffer then
    api.nvim_buf_delete(terminal_buffer, { force = true })
  end
  terminal_buffer = nil
end

local function term_start_insert(args)
  local buf_end = false
  local line_count = api.nvim_buf_line_count(0)
  local current_line_number = api.nvim_win_get_cursor(0)[1]
  -- After changing buffer win_get_cursor always returns 1, 0
  if current_line_number == 1 then
    current_line_number = api.nvim_buf_get_mark(0, '"')[1]
  end
  if line_count == current_line_number then
    buf_end = true
  elseif line_count - current_line_number < 70 then
    -- New terminal buffer is filled with empty lines
    local lines = api.nvim_buf_get_lines(0, current_line_number, line_count, true)
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
  if terminal_buffer == nil or not api.nvim_buf_is_valid(terminal_buffer) then
    terminal_buffer = api.nvim_create_buf(true, false)
    api.nvim_create_autocmd("BufEnter", {
      buffer = terminal_buffer,
      callback = term_start_insert,
    })
    api.nvim_set_current_buf(terminal_buffer)
    vim.fn.termopen("fish", {
      on_exit = on_exit,
    })
  else
    api.nvim_set_current_buf(terminal_buffer)
  end
end

local procs_which_uses_esc = {
  nvim = true,
  vim = true,
  fzf = true,
}

local function is_proc_uses_esc(pid)
  if procs_which_uses_esc[api.nvim_get_proc(pid).name] then
    return true
  end
  for _, child_pid in ipairs(api.nvim_get_proc_children(pid)) do
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

api.nvim_create_autocmd("VimEnter", {
  desc = "Open terminal automatically on startup",
  once = true,
  callback = function()
    if vim.o.columns >= 200 and api.nvim_buf_get_name(0) == "" then
      cmd.vsplit()
      cmd.wincmd("l")
      terminal_open()
      api.nvim_exec_autocmds("TermOpen", {
        group = augroup,
        buffer = 0,
      })
      cmd.wincmd("h")
    end
  end,
})
