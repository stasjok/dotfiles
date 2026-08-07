;; extends

((html_tag) @injection.content
  (#set! injection.language "html")
  (#set! injection.include-children)
  (#set! injection.combined))

((syntaxhighlight) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
