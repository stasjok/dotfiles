M = {}

-- Set `runtimepath` for test environment
function M.set_rtp()
  for _, dir in ipairs(vim.opt.runtimepath:get()) do
    if vim.endswith(dir, "vim-pack-dir") then
      local config_home = vim.fn.stdpath("config")
      vim.opt.runtimepath = {
        "tests/nvim",
        config_home,
        dir,
        vim.env.VIMRUNTIME,
        config_home .. "/after",
      }
      vim.opt.packpath = {
        dir,
        vim.env.VIMRUNTIME,
      }
      break
    end
  end
end

return M
