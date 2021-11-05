-- Russian layout
vim.opt.langmap = {
  "аf",
  "б\\,",
  "вd",
  "гu",
  "дl",
  "еt",
  "ё`",
  "ж\\;",
  "зp",
  "иb",
  "йq",
  "кr",
  "лk",
  "мv",
  "нy",
  "оj",
  "пg",
  "рh",
  "сc",
  "тn",
  "уe",
  "фa",
  "х[",
  "цw",
  "чx",
  "шi",
  "щo",
  "ъ]",
  "ыs",
  "ьm",
  "э'",
  "ю.",
  "яz",
  "АF",
  "Б<",
  "ВD",
  "ГU",
  "ДL",
  "ЕT",
  "Ё~",
  "Ж:",
  "ЗP",
  "ИB",
  "ЙQ",
  "КR",
  "ЛK",
  "МV",
  "НY",
  "ОJ",
  "ПG",
  "РH",
  "СC",
  "ТN",
  "УE",
  "ФA",
  "Х{",
  "ЦW",
  "ЧX",
  "ШI",
  "ЩO",
  "Ъ}",
  "ЫS",
  "ЬM",
  'Э\\"',
  "Ю>",
  "ЯZ",
}

---Toggles keymap. If disabled, it enables it. It enabled,
---it toggles it in insert modes and disables it in normal mode.
---@return nil
function _G._toggle_keymap()
  local mode = vim.api.nvim_get_mode().mode
  local insert_modes = vim.tbl_contains({ "i", "c" }, mode)
  if vim.opt.keymap._value == "" then
    local extra_keys = ""
    if insert_modes then
      extra_keys = "<C-^>"
    end
    return vim.api.nvim_replace_termcodes(
      "<Cmd>set keymap=russian-jcukenwin<CR>" .. extra_keys,
      true,
      false,
      true
    )
  elseif insert_modes then
    return vim.api.nvim_replace_termcodes("<C-^>", true, false, true)
  else
    return vim.api.nvim_replace_termcodes("<Cmd>set keymap=<CR>", true, false, true)
  end
end
for _, m in ipairs({ "i", "n", "v", "c" }) do
  vim.api.nvim_set_keymap(m, "<M-i>", "v:lua._toggle_keymap()", { noremap = true, expr = true })
end
