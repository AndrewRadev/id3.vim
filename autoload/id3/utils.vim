function! id3#utils#FindTagValue(tag_name)
  let tag_pattern = '^'.a:tag_name.':\s*\(.*\)$'
  let tag_line    = search(tag_pattern, 'n')

  if tag_line <= 0
    return ''
  endif

  return substitute(trim(getline(tag_line)), tag_pattern, '\1', '')
endfunction
