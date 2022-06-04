local buf_delete = vim.api.nvim_buf_delete
local buf_is_valid = vim.api.nvim_buf_is_valid
local create_buf = vim.api.nvim_create_buf
local set_current_buf = vim.api.nvim_set_current_buf
local create_autocmd = vim.api.nvim_create_autocmd
local map = vim.keymap.set

vim.cmd([[
augroup terminal
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber sidescrolloff=0 signcolumn=auto
augroup END
]])

local function on_exit()
  buf_delete(_G._my_terminal_buffer, { force = true })
  _G._my_terminal_buffer = nil
end

local function terminal_open()
  if _G._my_terminal_buffer == nil or not buf_is_valid(_G._my_terminal_buffer) then
    _G._my_terminal_buffer = create_buf(true, false)
    create_autocmd("BufEnter", {
      buffer = _G._my_terminal_buffer,
      command = "startinsert",
    })
    set_current_buf(_G._my_terminal_buffer)
    vim.fn.termopen("fish", {
      on_exit = on_exit,
      env = { XDG_DATA_DIRS = vim.env.HOME .. "/.nix-profile/share" },
    })
  else
    set_current_buf(_G._my_terminal_buffer)
  end
end

map("n", "<Leader>t", terminal_open)
map("t", "<Esc>", "<C-\\><C-n>")
map("t", "<C-\\><Esc>", "<Esc>")
map("t", "<M-PageUp>", "<C-\\><C-n><PageUp>")
