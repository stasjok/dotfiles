local lua_ls = {}

---Read a contents of a file. Errors in case of errors.
---@param filename string
---@return string
local function read_file(filename)
  local file = assert(io.open(filename, "r"))
  local content = assert(file:read("*a"))
  file:close()
  return content
end

---Read the content of .luarc.json
---@param root_dir string
---@return table|nil
local function read_luarc(root_dir)
  local luarc_path = vim.fs.joinpath(root_dir, ".luarc.json")
  local luarc_content = vim.F.npcall(read_file, luarc_path)
    or vim.F.npcall(read_file, luarc_path .. "c")
    or ""
  luarc_content = require("plenary.json").json_strip_comments(luarc_content, {})
  if luarc_content then
    return vim.F.npcall(vim.json.decode, luarc_content)
  end
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

-- Path to neovim runtime
local runtime_path = vim.fs.joinpath(plugins["neovim-patched"], "share/nvim/runtime")
plugins["neovim-unwrapped"] = runtime_path
local library_for_dotfiles = vim.list_extend({
  "${3rd}/luv/library",
  "${3rd}/busted/library",
  "${3rd}/luassert/library",
}, vim.tbl_values(plugins))

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
  if vim.startswith(fname, "/nix/store/") or vim.startswith(fname, runtime_path) then
    local client = vim.lsp.get_clients({ name = "lua_ls" })[1]
    if client then
      local lua_rc = read_luarc(client.config.root_dir) or {}
      local lib = vim.tbl_get(lua_rc, "workspace", "library")
        or vim.tbl_get(lua_rc, "workspace.library")
        or vim.tbl_get(client, "config", "settings", "Lua", "workspace", "library")
        or {}
      if
        vim
          .iter(lib)
          :map(function(dir)
            return dir == "$VIMRUNTIME" and runtime_path or dir
          end)
          :any(function(dir)
            return dir == root_dir
          end)
      then
        root_dir = client.config.root_dir
      end
    end
  end
  return root_dir
end

---Change library
---@param config table
---@param root_dir string
function lua_ls.on_new_config(config, root_dir)
  local lua_rc = read_luarc(root_dir) or {}
  local lua_rc_has_runtime = vim.iter(lua_rc):any(function(key)
    return vim.startswith(key, "runtime")
  end)
  local lua_rc_has_workspace = vim.iter(lua_rc):any(function(key)
    return vim.startswith(key, "workspace")
  end)
  if lua_rc_has_runtime then
    config.settings.Lua.runtime = nil
  elseif vim.endswith(root_dir, "/dotfiles") then
    config.settings.Lua.runtime.path = {
      -- meta/3rd library from lua-language-server
      "library/?.lua",
      "library/?/init.lua",
      "lua/?.lua",
      "lua/?/init.lua",
    }
  end
  if lua_rc_has_workspace then
    config.settings.Lua.workspace = nil
  elseif vim.endswith(root_dir, "/dotfiles") then
    config.settings.Lua.workspace.library = library_for_dotfiles
  elseif vim.endswith(root_dir, "/neovim") then
    config.settings.Lua.workspace.library = {}
  end
end

lua_ls.cmd_env = {
  VIMRUNTIME = runtime_path,
}

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
        runtime_path,
        "${3rd}/luv/library",
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
