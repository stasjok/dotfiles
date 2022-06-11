local luasnip_expand_conditions = require("luasnip.extras.expand_conditions")

local expand_conditions = {}

expand_conditions.is_line_beginning = luasnip_expand_conditions.line_begin

return expand_conditions
