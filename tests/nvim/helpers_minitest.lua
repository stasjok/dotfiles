local helpers = {}

helpers.new_child = function()
  local child = MiniTest.new_child_neovim()

  child.setup = function()
    child.restart(
      { "-u", "nvim/init.lua", "--cmd", "set rtp^=nvim" },
      { nvim_executable = vim.env.NVIMPATH or "nvim" }
    )
    child.bo.readonly = false
  end

  return child
end

return helpers
