;; extends
; vim: ft=query
; Source: https://github.com/kartikvashistha/zed-ansible/blob/main/languages/yaml/injections.scm

; ── Case 1: {{ }}, {% %}, {# #} inside YAML string values ──────────────────
; Inject Jinja2 grammar into any YAML string scalar that contains a Jinja2
; delimiter. Covers double-quoted, single-quoted, block, and plain strings.

(
  [
    (double_quote_scalar)
    (single_quote_scalar)
    (block_scalar)
    (string_scalar)
  ] @injection.content
  (#lua-match? @injection.content "{[{%%#]")
  (#set! injection.language "jinja")
)

; ── Case 2: Bare Jinja2 expressions in Ansible conditional fields ────────────
; Ansible fields like `when:`, `changed_when:`, `failed_when:`, `until:` accept
; raw Jinja2 expressions WITHOUT {{ }} delimiters. These need the jinja_inline
; parser which understands bare expressions (the main jinja parser only parses
; content within {{ }}, {% %}, {# #} delimiters).

; (block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @_key))
;   value: (flow_node
;     (plain_scalar
;       (string_scalar) @injection.content))
;   (#any-of? @_key "when" "changed_when" "failed_when" "check_mode" "until")
;   (#set! injection.language "jinja_inline")
; )

; ── Case 3: Bare Jinja2 in block_sequence items under conditional keys ───────
; Handles list-style conditionals:
;   when:
;     - condition1
;     - condition2

; (block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @_key))
;   value: (block_node
;     (block_sequence
;       (block_sequence_item
;         (flow_node
;           (plain_scalar
;             (string_scalar) @injection.content)))))
;   (#any-of? @_key "when" "changed_when" "failed_when" "check_mode" "until")
;   (#set! injection.language "jinja_inline")
; )

; ── Case 4: Quoted bare conditionals ─────────────────────────────────────────
; Handles: when: "ansible_os_family == 'Debian'"

; (block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @_key))
;   value: (flow_node
;     (double_quote_scalar) @injection.content)
;   (#any-of? @_key "when" "changed_when" "failed_when" "check_mode" "until")
;   (#set! injection.language "jinja_inline")
; )

; (block_mapping_pair
;   key: (flow_node
;     (plain_scalar
;       (string_scalar) @_key))
;   value: (flow_node
;     (single_quote_scalar) @injection.content)
;   (#any-of? @_key "when" "changed_when" "failed_when" "check_mode" "until")
;   (#set! injection.language "jinja_inline")
; )
