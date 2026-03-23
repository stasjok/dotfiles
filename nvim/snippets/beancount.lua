local extend_decorator = require("luasnip.util.extend_decorator")

extend_decorator.register(s, { arg_indx = 1 })
local sb = extend_decorator.apply(s, {
  condition = expand_conds.is_line_beginning,
  show_condition = show_conds.is_line_beginning(),
})

local function date(pos)
  return c(pos, {
    {
      l(l.CURRENT_YEAR .. "-" .. l.CURRENT_MONTH .. "-"),
      dl(1, l.CURRENT_DATE),
    },
    {
      l(l.CURRENT_YEAR .. "-"),
      dl(1, l.CURRENT_MONTH .. "-" .. l.CURRENT_DATE),
    },
    {
      dl(1, l.CURRENT_YEAR .. "-" .. l.CURRENT_MONTH .. "-" .. l.CURRENT_DATE),
    },
  })
end

local function txn(pos)
  return sn(pos, { date(1), t(" * "), i(2) })
end

local function currency(pos, opts)
  return c(pos, {
    i(1, "RUB"),
    i(1, "CNY"),
    i(1, "USD"),
    i(1, "EUR"),
  }, opts)
end

return {
  -- Date
  s({ trig = "date", desc = "Date" }, { date(1) }),

  -- Transaction
  sb({ trig = "t", name = "transaction", desc = "Transaction" }, {
    txn(1),
  }),

  -- Interest transaction
  sb({ trig = "interest", desc = "Interest transaction" }, {
    txn(1),
    t(' "Interest '),
    c(2, { i(1, "payment"), i(1, "capitalization") }),
    t('" '),
    i(3),
    t({ "", "\tAssets:" }),
    cr(4, {
      r(1, "base", {
        i(1, "", { key = "account" }),
        t(" "),
        i(2, "1.00", { key = "amount" }),
        t(" "),
        currency(3, { key = "currency" }),
        -- TODO: Replace "  " with "\t"
        t({ "", "  Income:Interest -" }),
        l(l._1 .. " " .. l._2, { k("amount"), k("currency") }),
      }),
      {
        r(1, "base"),
        t({ "", "\tAssets:" }),
        l(l._1:match("^[^:]+:?"), k("account")),
        i(2),
        t(" 0.00 "),
        l(l._1, k("currency")),
      },
    }),
  }),
}
