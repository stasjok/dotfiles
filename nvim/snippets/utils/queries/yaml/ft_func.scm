(block_mapping_pair
  key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
  value: (flow_node [
    (plain_scalar (string_scalar))
    (double_quote_scalar)
    (single_quote_scalar)
  ] @value))

(block_mapping_pair
  key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
  value: (block_node
    (block_scalar) @value))

(block_mapping_pair
  key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (flow_node [
          (plain_scalar (string_scalar))
          (double_quote_scalar)
          (single_quote_scalar)
        ] @value)))))

(block_mapping_pair
  key: (flow_node) @key (#not-any-of? @key "when" "that" "var")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_scalar) @value)))))

(block_mapping_pair
  key: (flow_node) @key (#any-of? @key "when" "that" "var")
  value: (flow_node [
    (plain_scalar (string_scalar))
    (double_quote_scalar)
    (single_quote_scalar)
  ] @jinja))

(block_mapping_pair
  key: (flow_node) @key (#any-of? @key "when" "that" "var")
  value: (block_node
    (block_scalar) @jinja))

(block_mapping_pair
  key: (flow_node) @key (#any-of? @key "when" "that" "var")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (flow_node [
          (plain_scalar (string_scalar))
          (double_quote_scalar)
          (single_quote_scalar)
        ] @jinja)))))

(block_mapping_pair
  key: (flow_node) @key (#any-of? @key "when" "that" "var")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_scalar) @jinja)))))
