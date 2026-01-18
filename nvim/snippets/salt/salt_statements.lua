local jinja_statement_snippets = require("snippets.jinja_utils").jinja_statement_snippets

-- SaltStack jinja statements
return jinja_statement_snippets({
  load_yaml = {
    dscr = "Deserialize a YAML string to object",
    nodes = { t("as "), i(1, "var") },
    end_statement = "endload",
  },
  load_json = {
    dscr = "Deserialize a JSON string to object",
    nodes = { t("as "), i(1, "var") },
    end_statement = "endload",
  },
  load_text = {
    dscr = "Read a string to a variable",
    nodes = { t("as "), i(1, "var") },
    end_statement = "endload",
  },
  import_yaml = {
    dscr = "Deserialize a YAML file to object",
    nodes = {
      t('"'),
      i(1, "filename"),
      t('" as '),
      dl(2, l._1:match("[^/]*$"):match("^[^.]*"), 1),
    },
    block = false,
    inline = false,
  },
  import_json = {
    dscr = "Deserialize a JSON file to object",
    nodes = {
      t('"'),
      i(1, "filename"),
      t('" as '),
      dl(2, l._1:match("[^/]*$"):match("^[^.]*"), 1),
    },
    block = false,
    inline = false,
  },
  import_text = {
    dscr = "Read a file to a variable",
    nodes = {
      t('"'),
      i(1, "filename"),
      t('" as '),
      dl(2, l._1:match("[^/]*$"):match("^[^.]*"), 1),
    },
    block = false,
    inline = false,
  },
  profile = { dscr = "Profile block", nodes = { t('as "'), i(1, "name"), t('"') } },
})
