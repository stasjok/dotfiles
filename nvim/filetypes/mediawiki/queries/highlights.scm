;; extends
(italic) @markup.italic

(bold) @markup.strong

(bold_italic) @markup.italic @markup.strong

((syntaxhighlight
  (code) @markup.raw.block)
  (#set! priority 90))

[
  "<syntaxhighlight"
  "</syntaxhighlight>"
] @tag

"lang" @tag.attribute

"=" @operator

; Table
[
  "{|"
  "|}"
  "|"
  "|-"
  "|+"
  "!"
  "!!"
  "||"
] @punctuation.special

; html
(html_tag_name) @tag

[
  "<"
  ">"
  "</"
  "/>"
] @tag.delimiter

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.strong
  (#any-of? @_tag "strong" "b"))

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.italic
  (#any-of? @_tag "em" "i" "var"))

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.strikethrough
  (#any-of? @_tag "s" "del"))

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.underline
  (#eq? @_tag "u"))

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.raw
  (#any-of? @_tag "code" "kbd" "tt" "samp"))

(html_tag
  name: (html_tag_name) @_tag
  (text) @markup.raw.block
  (#eq? @_tag "pre" ))

; Hack for a broken inline syntaxhighlight
((ERROR) @tag
  (#eq? @tag "syntaxhighlight"))

((ERROR) @tag.attribute
  (#eq? @tag.attribute "inline"))
