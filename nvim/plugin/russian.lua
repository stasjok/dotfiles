local map_expr = require("map").map_expr
local replace_termcodes_wrap = require("map").replace_termcodes_wrap

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
local function toggle_keymap()
  local mode = vim.api.nvim_get_mode().mode
  local is_in_insert = mode == "i" or mode == "c"
  if vim.opt.keymap._value == "" then
    local extra_keys = ""
    if is_in_insert then
      extra_keys = "<C-^>"
    end
    return "<Cmd>set keymap=russian-jcukenwin<CR>" .. extra_keys
  elseif is_in_insert then
    return "<C-^>"
  else
    return "<Cmd>set keymap=<CR>"
  end
end

map_expr({ "!", "n", "v" }, "<M-i>", replace_termcodes_wrap(toggle_keymap))
