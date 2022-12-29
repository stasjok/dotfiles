local nil_ls = {}

nil_ls.on_new_config = function(new_config, root_dir)
  local formatter_command

  if root_dir:find("nixpkgs", 1, true) then
    formatter_command = { "nixpkgs-fmt" }
  elseif root_dir:find("home-manager", 1, true) then
    formatter_command = { "nixfmt" }
  else
    formatter_command = { "alejandra", "-" }
  end

  new_config.settings = vim.tbl_deep_extend("keep", new_config.settings or {}, {
    ["nil"] = { formatting = { command = formatter_command } },
  })
end

return nil_ls
