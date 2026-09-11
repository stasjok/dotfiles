(render_expression
  (expression) @jinja)

([
  (statement) ; top-level node for all oneline statements
  (autoescape_statement)
  (block_statement)
  (call_statement)
  (elif_statement)
  (filter_statement)
  (for_statement)
  (if_statement)
  (macro_statement)
  (pluralize_statement)
  (set_block_statement)
  (trans_statement)
  (with_statement)
] @jinja)

(content) @text
