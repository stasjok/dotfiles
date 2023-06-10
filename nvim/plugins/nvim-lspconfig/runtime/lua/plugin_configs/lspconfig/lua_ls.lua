local util = require("lspconfig.util")
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
  return util.root_pattern(unpack(root_files))(fname)
    or util.root_pattern("lua")(fname)
    or util.find_git_ancestor(fname)
end

---Find first pattern in runtime and return realpath of it
---@param pattern string
---@return string
local function runtime(pattern)
  local found = get_runtime({ pattern }, false, { is_lua = true }) --[=[@as string[]]=]
  return fs_realpath(found[1])
end

---Returns plugin directory for require path
---@param require_path string
---@return string
local function plugin_dir(require_path)
  return require_path:sub(1, require_path:find("/lua/[%w_-]+$") - 1)
end

local library = {
  runtime("types/stable"),
  vim.env.VIMRUNTIME,
  "${3rd}/luv/library",
  "${3rd}/busted/library",
  "${3rd}/luassert/library",
  plugin_dir(runtime("lua/plenary")),
  runtime("lua/mini/test.lua"),
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
      library = library,
    },
  },
}

return lua_ls
