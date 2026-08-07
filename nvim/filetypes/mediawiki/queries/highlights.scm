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

; Conceal bold/italics
([
  "''"
  "'''"
  "'''''"
] @conceal
(#set! conceal ""))

; Conceal highlighted html tags
((html_tag
  "<" @conceal
  name: (html_tag_name) @conceal @_tag
  ">" @conceal
  "</" @conceal
  (html_tag_name) @conceal
  ">" @conceal)
  (#any-of? @_tag "i" "em" "var" "strong" "b" "s" "del" "u" "code" "kbd" "tt" "samp" "pre")
  (#set! conceal ""))

; Conceal link symbols
(wikilink
  [
    "[["
    "|" @punctuation.bracket
    "]]"
  ] @conceal
  (#set! conceal ""))

; Conceal link url only if there is a page name
(wikilink
  (wikilink_page) @conceal
  (page_name_segment)
  (#set! conceal ""))

; Conceal external link symbols
(external_link
  [
    "["
    "]" @conceal
  ] @conceal
  (#set! conceal ""))

; Conceal link url only if there is a link name
(external_link
  (url) @_url @conceal
  (page_name_segment)
  (#offset! @_url 0 0 0 1)
  (#set! conceal ""))

; Conceal image links
(medialink
  [
    "[["
    "]]"
  ] @conceal
  (#set! conceal ""))

; Conceal image links only if there is no a caption
(medialink
  (filename) @conceal
  .
  "|" @punctuation.bracket @conceal
  (file_caption)
  (#set! conceal ""))

; Conceal syntaxhighlight blocks
(syntaxhighlight
  [
    "<syntaxhighlight"
    "lang"
    "="
    "\""
    (code_language)
    (html_attribute)
    ">"
    "</syntaxhighlight>"
  ] @conceal
  (#set! conceal ""))

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
