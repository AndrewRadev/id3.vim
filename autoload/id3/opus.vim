function! id3#opus#Read(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open opus metadata: ".a:filename
    return
  endif

  let command_output = systemlist('opustags '. shellescape(a:filename))
  if v:shell_error
    echoerr "There was an error executing the `opustags` command: ".string(command_output)
    return
  endif

  let tags = {}
  let tag_regex = '^\w\+\zs='

  for line in command_output
    if line =~ tag_regex
      let [tag_name, value] = split(line, tag_regex)
      let tags[tag_name] = value
    endif
  endfor

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:       '.get(tags, 'title', ''),
        \   'Artist:      '.get(tags, 'artist', ''),
        \   'Album:       '.get(tags, 'album', ''),
        \   'Date:        '.get(tags, 'date', ''),
        \   'Genre:       '.get(tags, 'genre', ''),
        \   'Description: '.get(tags, 'DESCRIPTION', ''),
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=audio.opus
endfunction

function! id3#opus#Update(filename)
  let new_filename = id3#utils#FindTagValue('File')

  let tags             = {}
  let tags.title       = id3#utils#FindTagValue('Title')
  let tags.artist      = id3#utils#FindTagValue('Artist')
  let tags.album       = id3#utils#FindTagValue('Album')
  let tags.date        = id3#utils#FindTagValue('Date')
  let tags.genre       = id3#utils#FindTagValue('Genre')
  let tags.DESCRIPTION = id3#utils#FindTagValue('Description')

  let command_line = 'opustags -i '
  for [key, value] in items(tags)
    if value != ''
      let command_line .= '--set '.key.'='.shellescape(value).' '
    endif
  endfor
  let command_line .= shellescape(a:filename)

  let output = system(command_line)
  if v:shell_error
    echoerr "There was an error executing the `opustags` command: ".output
    return
  endif

  if new_filename != a:filename
    call rename(a:filename, new_filename)
    exe 'file '.fnameescape(new_filename)
    %delete _
    call id3#ReadOpus(new_filename)
  endif

  set nomodified
endfunction
