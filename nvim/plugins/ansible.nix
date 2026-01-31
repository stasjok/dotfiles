{
  plugins.ansible = {
    enable = true;

    settings = {
      attribute_highlight = "od";
      unindent_after_newline = 1;
      extra_keywords_highlight = 1;
      template_syntaxes = {
        "*.sh.j2" = "sh";
      };
    };
  };
}
