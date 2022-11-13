local status, kanagawa = pcall(require, "kanagawa")

if status then
  kanagawa.setup({
    overrides = {
      -- Match cursor in terminal
      TermCursor = { bg = "#54546D" },
    },
  })
  kanagawa.load()
end
