-- Speed up loading Lua modules in Neovim
do
  local luacache_suffix = vim.fn.sha256(vim.o.runtimepath):sub(1, 7)
  local stdcache = vim.fn.stdpath("cache")
  _G.__luacache_config = {
    chunks = {
      enable = true,
      path = string.format("%s/luacache_chunks_%s", stdcache, luacache_suffix),
    },
    modpaths = {
      enable = true,
      path = string.format("%s/luacache_modpaths_%s", stdcache, luacache_suffix),
    },
  }
  require("impatient")
end
