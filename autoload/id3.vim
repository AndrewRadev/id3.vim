function! id3#ReadMp3(filename)
  let filename       = shellescape(a:filename)
  let format_string  = '%'.join(['t', 'a', 'l', 'n', 'y', 'g', 'c'], '\n%')
  let command_output = system("id3 -q '".format_string."' ".filename)

  let tags = split(command_output, "\n")
  let tags = map(tags, 'v:val != "<empty>" ? v:val : ""')
  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:    '.tags[0],
        \   'Artist:   '.tags[1],
        \   'Album:    '.tags[2],
        \   'Track No: '.tags[3],
        \   'Year:     '.tags[4],
        \   'Genre:    '.tags[5],
        \   'Comment:  '.tags[6],
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=mp3
endfunction

function! id3#UpdateMp3(filename)
  let tags   = {}
  let tags.t = s:FindTagValue('Title')
  let tags.a = s:FindTagValue('Artist')
  let tags.l = s:FindTagValue('Album')
  let tags.n = s:FindTagValue('Track No')
  let tags.y = s:FindTagValue('Year')
  let tags.g = s:FindTagValue('Genre')
  let tags.c = s:FindTagValue('Comment')

  let command_line = 'id3 '
  for [key, value] in items(tags)
    if value != ''
      let command_line .= '-'.key.' '.shellescape(value).' '
    endif
  endfor
  let command_line .= shellescape(a:filename)

  let output = system(command_line)
  if v:shell_error
    echoerr output
  endif

  set nomodified
endfunction

function! s:FindTagValue(tag_name)
  let tag_pattern = '^'.a:tag_name.':\s*\(.*\)$'
  let tag_line    = search(tag_pattern, 'n')

  if tag_line <= 0
    return ''
  endif

  return substitute(getline(tag_line), tag_pattern, '\1', '')
endfunction
