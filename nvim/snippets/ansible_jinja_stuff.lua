local s = require("luasnip.nodes.snippet").S
local t = require("luasnip.nodes.textNode").T
local i = require("luasnip.nodes.insertNode").I
local c = require("luasnip.nodes.choiceNode").C

return {
  s({ trig = "ansible_facts", dscr = "Ansible fact" }, {
    t('ansible_facts["'),
    c(1, {
      i(1, "os_family"),
      i(1, "distribution"),
      i(1, "distribution_major_version"),
      i(1, "distribution_release"),
      i(1, "hostname"),
      i(1, "fqdn"),
      i(1, "virtualization_type"),
      i(1, "virtualization_role"),
    }),
    t('"]'),
  }),
}
