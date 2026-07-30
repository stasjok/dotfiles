((comment) @injection.content
  (#set! injection.language "comment"))

(block_mapping_pair
  value: [
    (flow_node [
      (plain_scalar
        (string_scalar) @injection.content)
      (double_quote_scalar) @injection.content
      (single_quote_scalar) @injection.content
    ])
    (block_node
      (block_scalar) @injection.content)
  ]
  (#set! injection.language "jinja"))


(flow_pair
  value: (flow_node [
    (plain_scalar
      (string_scalar) @injection.content)
    (double_quote_scalar) @injection.content
    (single_quote_scalar) @injection.content
  ])
  (#set! injection.language "jinja"))

(block_sequence_item [
  (flow_node [
    (plain_scalar
      (string_scalar) @injection.content)
    (double_quote_scalar) @injection.content
    (single_quote_scalar) @injection.content
  ])
  (block_node
    (block_scalar) @injection.content)
]
(#set! injection.language "jinja"))

(flow_sequence
  (flow_node [
    (plain_scalar
      (string_scalar) @injection.content)
    (double_quote_scalar) @injection.content
    (single_quote_scalar) @injection.content
  ])
  (#set! injection.language "jinja"))
