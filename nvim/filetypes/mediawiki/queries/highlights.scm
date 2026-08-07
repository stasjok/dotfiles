;; extends

(italic) @markup.italic

(bold) @markup.strong

(bold_italic) @markup.italic @markup.strong

((syntaxhighlight
  (code) @markup.raw.block)
  (#set! priority 90))

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

; Hack for a broken inline syntaxhighlight
((ERROR) @tag
  (#eq? @tag "syntaxhighlight"))

((ERROR) @tag.attribute
  (#eq? @tag.attribute "inline"))
