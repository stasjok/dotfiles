;; extends

; Add highlights missing in nvim-treesitter
((element
  (start_tag
    (tag_name) @_tag)
  (text) @markup.italic)
  (#eq? @_tag "var"))

((element
  (start_tag
    (tag_name) @_tag)
  (text) @markup.raw)
  (#any-of? @_tag "tt" "samp"))

((element
  (start_tag
    (tag_name) @_tag)
  (text) @markup.raw.block)
  (#eq? @_tag "pre"))
