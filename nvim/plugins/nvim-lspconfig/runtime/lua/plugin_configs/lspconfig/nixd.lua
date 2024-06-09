local nixd = {}

---@param filename string
---@return string?
function nixd.root_dir(filename)
  local root_dir = vim.fs.root(filename, { "flake.nix", ".git" })
  -- 'lib' directory inside nixpkgs repository also contains flake.nix, ignore it
  if root_dir and vim.fs.basename(root_dir) == "lib" then
    root_dir = vim.fs.root(vim.fs.dirname(root_dir), { "flake.nix", ".git" }) or root_dir
  end
  return root_dir
end

---@param config lspconfig.Config
---@param root_dir string
nixd.on_new_config = function(config, root_dir)
  local settings = vim.defaulttable()

  local dirname = vim.fs.basename(root_dir)
  local flake = string.format('(builtins.getFlake "git+file:%s")', root_dir)

  -- Default nixpkgs
  settings.nixpkgs.expr = '(builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem}'

  -- My dotfiles
  if dirname == "dotfiles" then
    settings.nixpkgs.expr = flake .. ".legacyPackages.${builtins.currentSystem}"
    settings.options["home-manager"].expr = flake .. ".homeConfigurations.stas.options"
  -- Nixpkgs
  elseif dirname == "nixpkgs" then
    settings.nixpkgs.expr = string.format(
      "import %s {localSystem = builtins.currentSystem;}",
      vim.fs.joinpath(root_dir, "pkgs/top-level")
    )
    settings.options.nixos.expr = string.format(
      "(import %s {modules = [];}).options",
      vim.fs.joinpath(root_dir, "nixos/lib/eval-config.nix")
    )
  -- Home-manager
  elseif dirname == "home-manager" then
    settings.options["home-manager"].expr = string.format(
      '(import %s {configuration = {home = {stateVersion = "24.05"; username = "nixd"; homeDirectory = "/home/nixd";};}; pkgs = %s;}).options',
      vim.fs.joinpath(root_dir, "modules"),
      settings.nixpkgs.expr
    )
  end

  config.settings = vim.tbl_deep_extend("force", config.settings or {}, { nixd = settings })
end

---@param client vim.lsp.Client
nixd.on_init = function(client)
  ---@type lsp.ServerCapabilities
  local overrrides = {
    documentHighlightProvider = false,
    documentSymbolProvider = false,
    hoverProvider = false,
  }
  -- Override server capabilities
  client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, overrrides)
  -- Disable semantic tokens
  client.server_capabilities.semanticTokensProvider = nil
end

return nixd
