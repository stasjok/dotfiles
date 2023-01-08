local util = require("lspconfig.util")
local get_runtime = vim.api.nvim__get_runtime
local fs_realpath = vim.loop.fs_realpath

local sumneko_lua = {}

local root_files = {
  ".luarc.json",
  ".luarc.jsonc",
  ".luacheckrc",
  ".stylua.toml",
  "stylua.toml",
  "selene.toml",
  "selene.yml",
}

function sumneko_lua.root_dir(fname)
  return util.root_pattern(unpack(root_files))(fname)
    or util.root_pattern("lua")(fname)
    or util.find_git_ancestor(fname)
end

local library = get_runtime({ "types/stable" }, true, { is_lua = true }) --[=[@as string[]]=]
for i = 1, #library do
  library[i] = fs_realpath(library[i])
end
library[#library + 1] = vim.env.VIMRUNTIME
local library_dotfiles = get_runtime({ "lua/luassert", "lua/plenary" }, true, { is_lua = true }) --[=[@as string[]]=]
for i = 1, #library_dotfiles do
  library_dotfiles[i] =
    fs_realpath(library_dotfiles[i]:sub(1, library_dotfiles[i]:find("/lua/[%w_-]+$") - 1))
end
library_dotfiles[#library_dotfiles + 1] = "${3rd}/busted"
library_dotfiles[#library_dotfiles + 1] = "${3rd}/luassert"
local minitest = get_runtime({ "lua/mini/test.lua" }, true, { is_lua = true }) --[=[@as string[]]=]
---@diagnostic disable-next-line: missing-parameter
vim.list_extend(library_dotfiles, minitest)
---@diagnostic disable-next-line: missing-parameter
vim.list_extend(library_dotfiles, library)
local path = { "lua/?.lua", "lua/?/init.lua" }
local path_dotfiles = {
  -- meta/3rd library from lua-language-server
  "library/?.lua",
  "library/?/init.lua",
  "nvim/lua/?.lua",
  "nvim/lua/?/init.lua",
  "lua/?.lua",
  "lua/?/init.lua",
}

---Search lua files in `nvim/lua` directory when working with dotfiles
---@param new_config table
---@param root_dir string
function sumneko_lua.on_new_config(new_config, root_dir)
  if root_dir:sub(-9) == "/dotfiles" then
    new_config.settings.Lua.workspace.library = library_dotfiles
    new_config.settings.Lua.runtime.path = path_dotfiles
  else
    new_config.settings.Lua.workspace.library = library
    new_config.settings.Lua.runtime.path = path
  end
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
      path = path,
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
