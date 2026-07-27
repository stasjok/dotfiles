((comment) @injection.content
  (#set! injection.language "comment"))

([
  (double_quote_scalar)
  (single_quote_scalar)
  (block_scalar)
  (string_scalar)
] @injection.content
  (#set! injection.language "jinja"))
