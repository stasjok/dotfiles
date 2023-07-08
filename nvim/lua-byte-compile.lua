for _, file in ipairs(_G.arg) do
  local chunk = assert(loadfile(file))
  -- Re-create symbolic link as a regular file
  assert(os.remove(file))
  local out = assert(io.open(file, "wb"))
  assert(out:write(string.dump(chunk)))
  out:close()
end
