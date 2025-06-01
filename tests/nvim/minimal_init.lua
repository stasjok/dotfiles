-- Reduce the number of scripts loaded
vim.cmd.filetype("off")
vim.cmd.syntax("off")

-- Set runtime
vim.o.runtimepath = "tests/nvim/runtime,"
  .. assert(vim.env.runtimePaths, "No 'runtimePaths' environment variable defined")
vim.o.packpath = assert(vim.env.packPaths, "No 'packPaths' environment variable defined")
