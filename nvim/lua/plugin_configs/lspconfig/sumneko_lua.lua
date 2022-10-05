local util = require("lspconfig.util")
local on_attach = require("plugin_configs.lspconfig.utils").on_attach
local get_runtime = vim.api.nvim__get_runtime
local fs_realpath = vim.loop.fs_realpath

local sumneko_lua = {}

local root_files = {
  "lua",
  ".luarc.json",
  ".luacheckrc",
  ".stylua.toml",
  "stylua.toml",
  "selene.toml",
}

function sumneko_lua.root_dir(fname)
  return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
end

function sumneko_lua.on_attach(client, buffer)
  on_attach(client, buffer, { format = false })
end

local library = get_runtime({ "" }, true, { is_lua = true })
for i = 1, #library do
  library[i] = fs_realpath(library[i])
end

sumneko_lua.settings = {
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
      pathStrict = true,
    },
    semantic = {
      enable = false,
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

return sumneko_lua
