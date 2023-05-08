local rust_analyzer = {}

function rust_analyzer.root_dir(fname)
  -- Re-use language server for libraries
  if fname:sub(1, 11) == "/nix/store/" or fname:find("/.cargo/registry/src/", 5, true) then
    local clients = vim.lsp.get_active_clients({ name = "rust_analyzer" })
    if clients[1] then
      return clients[1].config.root_dir
    end
  end

  return require("lspconfig.server_configurations.rust_analyzer").default_config.root_dir(fname)
end

return rust_analyzer
