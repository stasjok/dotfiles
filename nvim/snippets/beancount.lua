local extend_decorator = require("luasnip.util.extend_decorator")

extend_decorator.register(s, { arg_indx = 1 })
local sb = extend_decorator.apply(s, {
  condition = expand_conds.is_line_beginning,
  show_condition = show_conds.is_line_beginning(),
})

local function today(pos, key)
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
  }, { key = key or "date" })
end

local function date(pos, key)
  return sn(pos, parse(nil, "${1:$CURRENT_YEAR-${2:$CURRENT_MONTH-$CURRENT_DATE}}"), { key = key })
end

local function txn(pos)
  return sn(pos, { today(1), t(" * "), i(2) })
end

local function currency(pos, key)
  return c(pos, {
    i(1, "RUB"),
    i(1, "CNY"),
    i(1, "USD"),
    i(1, "EUR"),
  }, { key = key or "currency" })
end

local function position(pos, key, keys)
  keys = keys or {}
  return sn(pos, {
    i(1, "100.00", { key = keys.amount_key or "amount" }),
    t(" "),
    currency(2, keys.currency_key),
  }, { key = key or "position" })
end

local function account(pos, key)
  key = key or "account"
  local r_key = key .. "_name"
  return cr(pos, {
    { t("Assets:"), r(1, r_key, i(1, "Account")) },
    { t("Liabilities:"), r(1, r_key) },
    { t("Income:"), r(1, r_key) },
    { t("Expenses:"), r(1, r_key) },
    { t("Equity:"), r(1, r_key) },
  }, { key = key })
end

local function directive(pos, name, keys)
  keys = keys or {}
  return sn(pos, { today(1, keys.date_key), t(" " .. name .. " "), account(2, keys.account_key) })
end

---@class snippets.beancount.meta.opts
---@field default? string|table Default value or node
---@field quote_value? boolean Whether to quote the value
---@field value_key? string Value node key

---@param pos integer
---@param key string
---@param opts? snippets.beancount.meta.opts
---@return any
local function meta(pos, key, opts)
  ---@type snippets.beancount.meta.opts
  opts = opts or {}
  local value_key = opts.value_key or key .. "_value"
  local nodes = {
    t(key .. ": " .. (opts.quote_value and '"' or "")),
    type(opts.default) == "table" and sn(1, { opts.default }, { key = value_key })
      or i(1, opts.default, { key = value_key }),
  }
  if opts.quote_value then
    table.insert(nodes, t('"'))
  end
  return sn(pos, nodes)
end

return {
  -- Date
  s({ trig = "date", desc = "Date" }, { today(1) }),

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
        position(2),
        -- TODO: Replace "  " with "\t"
        t({ "", "  Income:Interest -" }),
        l(l._1, k("position")),
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

  -- Open directive
  sb({ trig = "open", desc = "Open directive" }, {
    m(k("account"), ":Deposit", "*** " .. l._1:gsub("^Assets:", "", 1) .. "\n\n"),
    directive(1, "open"),
    t(" "),
    currency(2),
    d(3, function(args)
      ---@type string
      local acc = args[1][1]
      ---@type string
      local open_date = args[2][1]

      local acc_type
      if acc:find("^Assets:[^:]+$") then
        acc_type = "bank"
      elseif acc:find("Current", 10, true) then
        acc_type = "current"
      elseif acc:find("Savings", 10, true) then
        acc_type = "savings"
      elseif acc:find("Deposit", 10, true) then
        acc_type = "deposit"
      elseif acc:find("DebitCard", 10, true) then
        acc_type = "debitcard"
      elseif acc:find("CreditCard", 10, true) then
        acc_type = "creditcard"
      end

      local metas = {}
      if acc_type == "bank" then
        vim.list_extend(metas, {
          { key = "bank", opts = { quote_value = true } },
          { key = "bic", opts = { quote_value = true } },
        })
      elseif
        vim.list_contains({ "current", "savings", "debitcard", "creditcard", "deposit" }, acc_type)
      then
        table.insert(metas, { key = "number", opts = { quote_value = true } })

        if acc_type == "debitcard" or acc_type == "creditcard" then
          table.insert(metas, { key = "card_number", opts = { quote_value = true } })

          if acc_type == "creditcard" then
            table.insert(metas, { key = "credit_limit", opts = { default = position(1) } })
          end
        end

        if acc_type == "savings" or acc_type == "deposit" then
          if acc_type == "deposit" then
            vim.list_extend(metas, {
              {
                pre = t({ "start: " .. open_date, "\t" }),
                key = "top_up",
                opts = { default = date(1, "top_up_date") },
              },
              { key = "end", opts = { default = date(1, "end_date") } },
            })
          end

          table.insert(metas, { key = "interest_rate" })
        end
      end

      return sn(
        nil,
        vim
          .iter(metas)
          :enumerate()
          :map(function(i, item)
            local res = { t({ "", "\t" }) }
            if item.pre then
              table.insert(res, item.pre)
            end
            table.insert(res, meta(i, item.key, item.opts))
            return res
          end)
          :flatten(1)
          :totable()
      )
    end, { k("account"), k("date") }),
  }),

  -- Close directive
  sb({ trig = "close", desc = "Close directive" }, {
    directive(1, "close"),
    t({ "", "" }),
    f(function(args)
      local y, m, d = args[1][1]:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
      return os.date("%Y-%m-%d", os.time({
        year = tonumber(y or os.date("%Y")),
        month = tonumber(m or os.date("%m")),
        day = tonumber(d or os.date("%d")),
      }) + 86400)
    end, k("date")),
    t(" balance "),
    l(l._1, k("account")),
    t(" 0.00 "),
    currency(2),
  }),
}
