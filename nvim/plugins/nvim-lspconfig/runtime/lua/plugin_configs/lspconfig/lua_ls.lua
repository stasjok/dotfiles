local get_runtime = vim.api.nvim__get_runtime
local fs_realpath = vim.loop.fs_realpath

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
  local reuse_client
  if vim.startswith(fname, "/nix/store/") or vim.startswith(fname, vim.env.VIMRUNTIME) then
    local client = vim.lsp.get_active_clients({ name = "lua_ls" })[1]
    reuse_client = client and client.config.root_dir
  end
  return reuse_client
    or vim.fs.dirname(vim.fs.find(root_files, {
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
end

---Find first pattern in runtime and return realpath of it
---@param pattern string
---@return string
local function runtime(pattern)
  local found = get_runtime({ pattern }, false, { is_lua = true }) --[=[@as string[]]=]
  return assert(fs_realpath(found[1]))
end

-- TODO: Use vim.iter in neovim 0.10
local library_for_dotfiles = {}
local std_config = vim.fn.stdpath("config")
for _, path in
  ipairs(get_runtime({ "" }, true, { is_lua = true }) --[=[@as string[]]=])
do
  local realpath = fs_realpath(path)
  if realpath ~= std_config then
    table.insert(library_for_dotfiles, realpath)
  end
end
table.insert(library_for_dotfiles, "${3rd}/busted/library")
table.insert(library_for_dotfiles, "${3rd}/luassert/library")

---Change library
---@param config table
---@param root_dir string
function lua_ls.on_new_config(config, root_dir)
  if vim.endswith(root_dir, "/dotfiles") then
    config.settings.Lua.workspace.library = library_for_dotfiles
  elseif vim.endswith(root_dir, "/neovim") then
    config.settings.Lua.workspace.library = { runtime("types/stable") }
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
        runtime("types/stable"),
        vim.env.VIMRUNTIME,
      },
      ignoreDir = {
        "/types/nightly/",
        "/types/override/",
        "/tests/",
        "/test/",
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
