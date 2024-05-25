-- Conceal in markdown help files
if vim.bo.buftype == "help" then
  vim.wo[0][0].conceallevel = 2
  vim.wo[0][0].concealcursor = "nc"
end
