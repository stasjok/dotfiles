return {
  s({ trig = "if", dscr = "Inline if expression" }, {
    cr(1, {
      {
        r(1, 1, { i(2, "if_true"), t(" if "), i(1, "condition") }),
        t(" else "),
        i(2, "if_false"),
      },
      r(1, 1),
    }),
  }),
}
