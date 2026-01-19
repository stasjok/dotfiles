{
  snippets.filetype.mediawiki = {
    lsp = {
      a = {
        prefix = [
          "a"
          "а"
        ];
        description = "Internal link";
        body = "[[\${1:\${2:page#section}|$3}]]";
      };
      abbr = {
        prefix = [
          "abbr"
          "аббр"
        ];
        description = "Abbreviation";
        body = "<abbr title=\"\${2:meaning}\">\${1:$TM_SELECTED_TEXT}</abbr>";
      };
      ae = {
        prefix = [
          "ae"
          "ае"
        ];
        description = "External link";
        body = "[\${1:\${2:url} $3}]";
      };
      b = {
        prefix = [
          "b"
          "б"
        ];
        description = "Bold text";
        body = "'''\${1:$TM_SELECTED_TEXT}'''";
      };
      bi = {
        prefix = [
          "bi"
          "би"
        ];
        description = "Bold and italic text";
        body = "'''''\${1:$TM_SELECTED_TEXT}'''''";
      };
      blockquote = {
        prefix = [
          "blockquote"
          "блокквоут"
        ];
        description = "Blockquote";
        body = "<blockquote>\${1:$TM_SELECTED_TEXT}</blockquote>";
      };
      br = {
        prefix = [
          "br"
          "бр"
        ];
        description = "Line break";
        body = "<br />";
      };
      category = {
        prefix = [
          "category"
          "категория"
        ];
        description = "Category";
        body = "[[Category:\${1:Name}]]";
      };
      code = {
        prefix = [
          "code"
          "код"
        ];
        description = "Source code";
        body = "<code>\${1:$TM_SELECTED_TEXT}</code>";
      };
      cs = {
        prefix = "cs";
        description = "Column span";
        body = "colspan=\"\${1:2}\"|";
      };
      del = {
        prefix = [
          "del"
          "дел"
        ];
        description = "Deleted text";
        body = "<del>\${1:$TM_SELECTED_TEXT}</del>";
      };
      em = {
        prefix = [
          "em"
          "ем"
        ];
        description = "Emphasized text";
        body = "<em>\${1:$TM_SELECTED_TEXT}</em>";
      };
      h2 = {
        prefix = [
          "h2"
          "з2"
        ];
        description = "Heading level 2";
        body = "== \${1:$TM_SELECTED_TEXT} ==";
      };
      h3 = {
        prefix = [
          "h3"
          "з3"
        ];
        description = "Heading level 3";
        body = "=== \${1:$TM_SELECTED_TEXT} ===";
      };
      h4 = {
        prefix = [
          "h4"
          "з4"
        ];
        description = "Heading level 4";
        body = "==== \${1:$TM_SELECTED_TEXT} ====";
      };
      h5 = {
        prefix = [
          "h5"
          "з5"
        ];
        description = "Heading level 5";
        body = "===== \${1:$TM_SELECTED_TEXT} =====";
      };
      h6 = {
        prefix = [
          "h6"
          "з6"
        ];
        description = "Heading level 6";
        body = "====== \${1:$TM_SELECTED_TEXT} ======";
      };
      hl = {
        prefix = [
          "hl"
          "хл"
        ];
        description = "Horizontal rule";
        body = "----";
      };
      i = {
        prefix = [
          "i"
          "и"
        ];
        description = "Italic text";
        body = "''\${1:$TM_SELECTED_TEXT}''";
      };
      ins = {
        prefix = [
          "ins"
          "инс"
        ];
        description = "Inserted text";
        body = "<ins>\${1:$TM_SELECTED_TEXT}</ins>";
      };
      kbd = {
        prefix = [
          "kbd"
          "кбд"
        ];
        description = "Keyboard input";
        body = "<kbd>\${1:$TM_SELECTED_TEXT}</kbd>";
      };
      nbs = {
        prefix = [
          "nbs"
          "нбс"
        ];
        description = "Non-breaking space";
        body = "&nbsp;";
      };
      nowiki = {
        prefix = [
          "nowiki"
          "ноувики"
        ];
        description = "Escape wiki markup";
        body = "<nowiki>\${1:$TM_SELECTED_TEXT}</nowiki>";
      };
      pre = {
        prefix = [
          "pre"
          "пре"
        ];
        description = "Preformatted text";
        body = "<pre>\n\${1:$TM_SELECTED_TEXT}\n</pre>";
      };
      preformatted = {
        prefix = "preformatted";
        description = "Preformatted text";
        body = "\${VISUAL/^/ /gm}";
      };
      q = {
        prefix = [
          "q"
          "к"
        ];
        description = "Quotes";
        body = "<q>\${1:$TM_SELECTED_TEXT}</q>";
      };
      redirect = {
        prefix = [
          "redirect"
          "редирект"
        ];
        description = "Redirect";
        body = "#REDIRECT [[\${1:page#section}]]";
      };
      rs = {
        prefix = "rs";
        description = "Row span";
        body = "rowspan=\"\${1:2}\"|";
      };
      s = {
        prefix = [
          "s"
          "с"
        ];
        description = "Struck-through text";
        body = "<s>\${1:$TM_SELECTED_TEXT}</s>";
      };
      samp = {
        prefix = [
          "samp"
          "сэмп"
        ];
        description = "Sample output";
        body = "<samp>\${1:$TM_SELECTED_TEXT}</samp>";
      };
      strong = {
        prefix = [
          "strong"
          "стронг"
        ];
        description = "Important text";
        body = "<strong>\${1:$TM_SELECTED_TEXT}</strong>";
      };
      syn = {
        prefix = [
          "syn"
          "син"
        ];
        description = "Syntax Highlight";
        body = "<syntaxhighlight lang=\"\${1:text}\">\n\${2:$TM_SELECTED_TEXT}\n</syntaxhighlight>";
      };
      syni = {
        prefix = [
          "syni"
          "сини"
        ];
        description = "Inline Syntax Highlight";
        body = "<syntaxhighlight lang=\"\${1:text}\" inline=\"1\">\${2:$TM_SELECTED_TEXT}</syntaxhighlight>";
      };
      t = {
        prefix = [
          "t"
          "т"
        ];
        description = "Table";
        body = "{| class=\"wikitable\"\n$0\n|}";
      };
      "t([rh])(m?)(\\d*)" = {
        prefix = "t([rh])(m?)(\\d*)";
        description = "Table rows or headers";
        body = "|-\n`!p num = match.group(3) or 0\nsep = '|' if match.group(1) == 'r' else '!'\nsep2 = '\\n' if match.group(2) else sep\nplaceholders = ['\${{{}:text{}}}'.format(i, i) for i in range(1, int(num)+1)]\nsnip.rv = sep+' ' + ' {}{} '.format(sep2, sep).join(placeholders)`";
      };
      tc = {
        prefix = "tc";
        description = "Table caption";
        body = "|+ $0";
      };
      u = {
        prefix = [
          "u"
          "ю"
        ];
        description = "Underlined text";
        body = "<u>\${1:$TM_SELECTED_TEXT}</u>";
      };
      var = {
        prefix = [
          "var"
          "вар"
        ];
        description = "Variable name";
        body = "<var>\${1:$TM_SELECTED_TEXT}</var>";
      };
    };
  };
}
