local vim = vim
local fs = vim.fs
local uv = vim.uv

local M = {}

---@param filename string
---@return string?
function M.root_dir(filename)
  local root_dir = fs.root(filename, { "flake.nix", ".git" })
  -- 'lib' directory inside nixpkgs repository also contains flake.nix, ignore it
  if root_dir and fs.basename(root_dir) == "lib" then
    root_dir = fs.root(fs.dirname(root_dir), { "flake.nix", ".git" }) or root_dir
  end
  return root_dir
end

---@param config lspconfig.Config
---@param root_dir string
M.on_new_config = function(config, root_dir)
  local settings = vim.defaulttable()

  -- Default nixpkgs
  settings.nixpkgs.expr = '(builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem}'

  local dirname = fs.basename(root_dir)
  if dirname == "dotfiles" then
    -- My dotfiles
    local flake = string.format('(builtins.getFlake "git+file:%s")', root_dir)
    settings.nixpkgs.expr = flake .. ".legacyPackages.${builtins.currentSystem}"
    settings.options["home-manager"].expr = flake .. ".homeConfigurations.stas.options"
  elseif
    dirname == "nixpkgs"
    or vim.endswith(dirname, "-source") and uv.fs_stat(fs.joinpath(root_dir, "pkgs/top-level"))
  then
    -- Nixpkgs
    settings.nixpkgs.expr = string.format(
      "import %s {localSystem = builtins.currentSystem;}",
      fs.joinpath(root_dir, "pkgs/top-level")
    )
    settings.options.nixos.expr = string.format(
      "(import %s {modules = [];}).options",
      fs.joinpath(root_dir, "nixos/lib/eval-config.nix")
    )
  elseif
    dirname == "home-manager"
    or vim.endswith(dirname, "-source") and uv.fs_stat(fs.joinpath(root_dir, "home-manager"))
  then
    -- Home-manager
    settings.options["home-manager"].expr = string.format(
      '(import %s {configuration = {home = {stateVersion = "24.05"; username = "nixd"; homeDirectory = "/home/nixd";};}; pkgs = %s;}).options',
      fs.joinpath(root_dir, "modules"),
      settings.nixpkgs.expr
    )
  elseif
    dirname == "nixvim"
    or vim.endswith(dirname, "-source")
      and uv.fs_stat(fs.joinpath(root_dir, "lib/autocmd-helpers.nix"))
  then
    -- Get only suboptions from programs.nixvim
    settings.options.nixos.expr = string.format(
      "(import %s/wrappers/standalone.nix %s {} {module = {};}).options",
      root_dir,
      settings.nixpkgs.expr
    )
  end

  config.settings = vim.tbl_deep_extend("force", config.settings or {}, { nixd = settings })
end

---@param client vim.lsp.Client
M.on_init = function(client)
  ---@type lsp.ServerCapabilities
  local overrrides = {
    documentHighlightProvider = false,
    documentSymbolProvider = false,
    hoverProvider = false,
    renameProvider = false,
  }
  -- Override server capabilities
  client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, overrrides)
  -- Disable semantic tokens
  client.server_capabilities.semanticTokensProvider = nil
end

return M
