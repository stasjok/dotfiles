local win_get_cursor = vim.api.nvim_win_get_cursor

local utils = {}

---Optimize `runtimepath` if running from Nix
function utils.set_rtp()
  local rtp = vim.opt.runtimepath:get()
  local vimpackdir
  for _, dir in ipairs(rtp) do
    if string.sub(dir, -12) == "vim-pack-dir" then
      vimpackdir = dir
      break
    end
  end
  if vimpackdir then
    local config_home = vim.env.XDG_CONFIG_HOME and vim.env.XDG_CONFIG_HOME .. "/nvim"
      or vim.env.HOME .. "/.config/nvim"
    vim.opt.runtimepath = {
      config_home,
      vimpackdir,
      vim.env.VIMRUNTIME,
      config_home .. "/after",
    }
    vim.opt.packpath = {
      vimpackdir,
      vim.env.VIMRUNTIME,
    }
  end
end

---Get 0-indexed cursor position for the window
---@param winnr integer? Window handle, or 0 for current window
---@return integer row
---@return integer col
function utils.get_cursor_0(winnr)
  winnr = winnr or 0
  local cursor = win_get_cursor(winnr) --[[@as {[1]: integer, [2]: integer}]]
  return cursor[1] - 1, cursor[2]
end

return utils
