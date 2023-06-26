for _, file in ipairs(_G.arg) do
  local chunk = assert(loadfile(file))
  local out = assert(io.open(file, "w+b"))
  assert(out:write(string.dump(chunk)))
  out:close()
end
