local snippets = {
  s({ trig = ".PHONY", dscr = "Phony Target" }, {
    t(".PHONY : "),
    rep(1),
    t({ "", "" }),
    i(1, "target"),
    t(" :"),
  }, {
    condition = expand_conds.is_line_beginning,
    show_condition = show_conds.is_line_beginning("%w."),
  }),
}

return snippets
