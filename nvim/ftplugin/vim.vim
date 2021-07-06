" Disable auto pairs for '"'
if has_key(g:AutoPairs, '"')
  let b:AutoPairs = copy(g:AutoPairs)
  call remove(b:AutoPairs, '"')
endif
