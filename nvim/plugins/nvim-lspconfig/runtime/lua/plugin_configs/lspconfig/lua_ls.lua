local lua_ls = {}

local root_files = {
  ".luarc.json",
  ".luarc.jsonc",
  ".luacheckrc",
  ".stylua.toml",
  "stylua.toml",
  "selene.toml",
  "selene.yml",
}

function lua_ls.root_dir(fname)
  local root_dir = vim.fs.dirname(vim.fs.find(root_files, {
    path = fname,
    upward = true,
    stop = vim.env.HOME,
    type = "file",
  })[1] or vim.fs.find({ "lua", ".git" }, {
    path = fname,
    upward = true,
    stop = vim.env.HOME,
    type = "directory",
  })[1])
  -- Re-use client when we open a plugin in nix store, but only if it's already in a library
  if vim.startswith(fname, "/nix/store/") or vim.startswith(fname, vim.env.VIMRUNTIME) then
    local client = vim.lsp.get_active_clients({ name = "lua_ls" })[1]
    if
      client
      and vim.list_contains(
        vim.tbl_get(client, "config", "settings", "Lua", "workspace", "library") or {},
        root_dir
      )
    then
      root_dir = client.config.root_dir
    end
  end
  return root_dir
end

---Read a contents of a file. Errors in case of errors.
---@param filename string
---@return string
local function read_file(filename)
  local file = assert(io.open(filename, "r"))
  local content = assert(file:read("*a"))
  file:close()
  return content
end

local plugins = {}
do
  local ok, plugins_json =
    pcall(read_file, vim.api.nvim_get_runtime_file("lua_ls_library.json", false)[1])
  if ok then
    plugins = vim.json.decode(plugins_json) --[[@as {[string]: string}]]
  else
    vim.notify(plugins_json, vim.log.levels.WARN)
  end
end

-- Path to type annotations
local types_path = plugins["neodev-nvim"]
-- Path to neovim runtime
local runtime_path = vim.fs.joinpath(plugins["neovim-patched"], "share/nvim/runtime")
plugins["neovim-unwrapped"] = runtime_path
local library_for_dotfiles = vim.list_extend({
  "${3rd}/busted/library",
  "${3rd}/luassert/library",
}, vim.tbl_values(plugins))

---Change library
---@param config table
---@param root_dir string
function lua_ls.on_new_config(config, root_dir)
  if vim.endswith(root_dir, "/dotfiles") then
    config.settings.Lua.workspace.library = library_for_dotfiles
    config.settings.Lua.runtime.path = {
      -- meta/3rd library from lua-language-server
      "library/?.lua",
      "library/?/init.lua",
      "lua/?.lua",
      "lua/?/init.lua",
    }
  elseif vim.endswith(root_dir, "/neovim") then
    config.settings.Lua.workspace.library = { types_path }
  end
end

lua_ls.settings = {
  Lua = {
    completion = {
      showWord = "Disable",
    },
    format = {
      enable = false,
    },
    hint = {
      enable = false,
    },
    runtime = {
      version = "LuaJIT",
      path = { "lua/?.lua", "lua/?/init.lua" },
    },
    telemetry = {
      enable = false,
    },
    window = {
      progressBar = false,
      statusBar = false,
    },
    workspace = {
      checkThirdParty = false,
      library = {
        types_path,
        runtime_path,
      },
      ignoreDir = {
        "/types/nightly/",
        "/types/override/",
        "/lua/plenary/busted.lua",
        "/tests/",
        "/test/",
        "/scripts/",
        "/plugin/",
        "/ftplugin/",
        "/syntax/",
        "/colors/",
        "/indent/",
      },
    },
  },
}

return lua_ls
