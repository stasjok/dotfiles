-- Speed up loading Lua modules in Neovim
do
  local luacache_suffix = vim.o.runtimepath:match("%w+%-vim%-pack%-dir")
  if luacache_suffix then
    luacache_suffix = luacache_suffix:sub(1, 7)
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
  end
  require("impatient")
end
