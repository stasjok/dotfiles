{ lib, ... }:
{
  opts = {
    # Default indentation settings
    shiftwidth = 4;
    softtabstop = -1;
    expandtab = true;

    # Enable mouse support
    mouse = "a";

    # Make <Esc> faster
    ttimeoutlen = 5;
    timeoutlen = 700;

    # Don't redraw the screen while executing macros
    lazyredraw = true;

    # Search settings
    ignorecase = true;
    smartcase = true;

    # Gutter settings
    cursorline = true;
    number = true;
    relativenumber = true;
    signcolumn = "yes";

    # Default border style of floating windows
    winborder = "single";

    # Make some context visible
    scrolloff = 6;
    sidescrolloff = 6;

    # Open all folds by default
    foldlevelstart = 99;

    # Terminal buffer limit
    scrollback = 80000;

    # Disable terminal cursor blinking
    guicursor = [
      "n-v-c-sm:block"
      "i-ci-ve:ver25"
      "r-cr-o:hor20"
      "t:block-TermCursor"
    ];

    # Fire CursorHold event faster
    updatetime = 300;

    # Use system bash as default shell (it's faster)
    shell = lib.nixvim.mkRaw "vim.uv.fs_stat('/bin/bash') and '/bin/bash' or 'bash'";

    # Show tabs and trailing spaces
    list = true;
    listchars = "tab:→ ,trail:⋅,extends:❯,precedes:❮";

    # Russian layout
    langmap = [
      "аf"
      "б\\,"
      "вd"
      "гu"
      "дl"
      "еt"
      "ё`"
      "ж\\;"
      "зp"
      "иb"
      "йq"
      "кr"
      "лk"
      "мv"
      "нy"
      "оj"
      "пg"
      "рh"
      "сc"
      "тn"
      "уe"
      "фa"
      "х["
      "цw"
      "чx"
      "шi"
      "щo"
      "ъ]"
      "ыs"
      "ьm"
      "э'"
      "ю."
      "яz"
      "АF"
      "Б<"
      "ВD"
      "ГU"
      "ДL"
      "ЕT"
      "Ё~"
      "Ж:"
      "ЗP"
      "ИB"
      "ЙQ"
      "КR"
      "ЛK"
      "МV"
      "НY"
      "ОJ"
      "ПG"
      "РH"
      "СC"
      "ТN"
      "УE"
      "ФA"
      "Х{"
      "ЦW"
      "ЧX"
      "ШI"
      "ЩO"
      "Ъ}"
      "ЫS"
      "ЬM"
      "Э\\\""
      "Ю>"
      "ЯZ"
    ];
  };
}
