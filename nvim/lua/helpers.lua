local helpers = {}

---Optimize `runtimepath` if running from Nix
function helpers.set_rtp()
  local rtp = vim.opt.runtimepath:get()
  if rtp[1]:find("vim-pack-dir", 12, true) then
    local config_home = vim.env.XDG_CONFIG_HOME and vim.env.XDG_CONFIG_HOME .. "/nvim"
      or vim.env.HOME .. "/.config/nvim"
    vim.opt.runtimepath = {
      config_home,
      rtp[1],
      vim.env.VIMRUNTIME,
      config_home .. "/after",
    }
    vim.opt.packpath = {
      rtp[1],
      vim.env.VIMRUNTIME,
    }
  end
end

return helpers
