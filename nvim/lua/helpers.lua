local helpers = {}

---Optimize `runtimepath` if running from Nix
function helpers.set_rtp()
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

return helpers
