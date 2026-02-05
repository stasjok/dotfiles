local map = {}

---Send keys to Nvim
---@param keys string Keys to be sended
---@param mode? string Behavior flags, see feedkeys()
---@param replace_termcodes? boolean If false, termcodes won't be replaced
---@param escape_csi? boolean If true, escape also CSI bytes
---@return nil
function map.feedkeys(keys, mode, replace_termcodes, escape_csi)
  mode = mode == nil and "" or mode
  keys = replace_termcodes == false and keys or vim.keycode(keys)
  escape_csi = escape_csi or false
  vim.api.nvim_feedkeys(keys, mode, escape_csi)
end

return map
