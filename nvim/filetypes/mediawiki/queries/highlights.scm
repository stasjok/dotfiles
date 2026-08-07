;; extends

(italic) @markup.italic

(bold) @markup.strong

(bold_italic) @markup.italic @markup.strong

(list_marker) @markup.list

((syntaxhighlight
  (code) @markup.raw.block)
  (#set! priority 90))

; Tables
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

; Hacks for a broken syntaxhighlight in many places
((ERROR) @tag
  (#any-of? @tag "syntaxhighlight" "/syntaxhighlight"))

((ERROR) @tag.attribute
  (#eq? @tag.attribute "inline"))

"lang" @tag.attribute

"=" @operator

([
  "<syntaxhighlight"
  "</syntaxhighlight>"
] @tag
(#set! priority 90))

[
  "<"
  ">"
  "</"
  "/>"
] @tag.delimiter
