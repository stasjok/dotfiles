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
    reuse_client =
      vim.tbl_get(vim.lsp.get_active_clients({ name = "lua_ls" }), 1, "config", "root_dir")
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

-- Path to a type annotations
local types_path =
  vim.iter(get_runtime({ "types/stable" }, false, { is_lua = true })):map(fs_realpath):next()

-- Lazy library
local library = vim.defaulttable(function()
  local std_config = vim.fn.stdpath("config")
  local library = vim
    .iter(get_runtime({ "" }, true, { is_lua = true }))
    :map(fs_realpath)
    :filter(function(path)
      return path ~= std_config
    end)
    :totable()
  table.insert(library, "${3rd}/busted/library")
  table.insert(library, "${3rd}/luassert/library")
  return library
end)

---Change library
---@param config table
---@param root_dir string
function lua_ls.on_new_config(config, root_dir)
  if vim.endswith(root_dir, "/dotfiles") then
    config.settings.Lua.workspace.library = library.dotfiles
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
        vim.env.VIMRUNTIME,
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
