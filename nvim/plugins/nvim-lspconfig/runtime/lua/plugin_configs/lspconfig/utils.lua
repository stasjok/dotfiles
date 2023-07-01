local M = {}

local completion_kind_icons = {
  Array = "",
  Boolean = "",
  Class = "󰊾",
  Color = "",
  Constant = "",
  Constructor = "",
  Enum = "󰕘",
  EnumMember = "󰕚",
  Event = "",
  Field = "",
  File = "󰈙",
  Folder = "󰝰",
  Function = "",
  Interface = "",
  Key = "󰌋",
  Keyword = "󰌈",
  Method = "󰡱",
  Module = "",
  Namespace = "",
  Null = "󰟢",
  Number = "󰎠",
  Object = "󰅩",
  Operator = "",
  Package = "",
  Property = "",
  Reference = "",
  Snippet = "󰘌",
  String = "",
  Struct = "",
  Text = "",
  TypeParameter = "󰊄",
  Unit = "",
  Value = "󱗽",
  Variable = "󰯍",
}

M.completion_kinds = {}
-- Prepend icon to completion kind
for kind, icon in pairs(completion_kind_icons) do
  M.completion_kinds[kind] = string.format("%s %s", icon, kind)
end

return M
