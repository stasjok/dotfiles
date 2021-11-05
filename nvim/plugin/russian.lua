local map = require("map").map
local replace_termcodes = require("map").replace_termcodes
local feedkeys = vim.api.nvim_feedkeys

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

---Enables russian-jcukenwin keymap if disabled, then toggles iminsert.
---@return nil
local function toggle_iminsert()
  ---@diagnostic disable-next-line: undefined-field
  if #vim.opt_local.keymap:get() == 0 then
    vim.opt_local.keymap = "russian-jcukenwin"
  end
  feedkeys(replace_termcodes("<C-^>"), "n", false)
end

map({ "!", "s" }, "<M-i>", toggle_iminsert)
