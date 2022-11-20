function! id3#flac#Read(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open FLAC metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let tag_names      = ['TITLE', 'ARTIST', 'ALBUM', 'TRACKNUMBER', 'DATE', 'GENRE', 'DESCRIPTION']
  let tag_string     = join(map(copy(tag_names), '"--show-tag=".v:val'), ' ')
  let command_output = systemlist('metaflac '.tag_string.' '.filename)

  if v:shell_error
    echoerr "There was an error executing the `metaflac` command: ".string(command_output)
    return
  endif

  let tags = {}
  for line in command_output
    let [tag_name, value] = split(line, '^\w\+\zs=')
    let tags[s:Upcase(tag_name)] = value
  endfor

  " fill in missing values
  for tag_name in tag_names
    if !has_key(tags, tag_name)
      let tags[s:Upcase(tag_name)] = ''
    endif
  endfor

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:       '.tags.TITLE,
        \   'Artist:      '.tags.ARTIST,
        \   'Album:       '.tags.ALBUM,
        \   'Track No:    '.tags.TRACKNUMBER,
        \   'Date:        '.tags.DATE,
        \   'Genre:       '.tags.GENRE,
        \   'Description: '.tags.DESCRIPTION,
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=audio.flac
endfunction

function! id3#flac#Update(filename)
  let new_filename = id3#utils#FindTagValue('File')

  let tags             = {}
  let tags.TITLE       = id3#utils#FindTagValue('Title')
  let tags.ARTIST      = id3#utils#FindTagValue('Artist')
  let tags.ALBUM       = id3#utils#FindTagValue('Album')
  let tags.TRACKNUMBER = id3#utils#FindTagValue('Track No')
  let tags.DATE        = id3#utils#FindTagValue('Date')
  let tags.GENRE       = id3#utils#FindTagValue('Genre')
  let tags.DESCRIPTION = id3#utils#FindTagValue('Description')

  let command_line = 'metaflac '
  for [key, value] in items(tags)
    if value != ''
      let command_line .= '--remove-tag='.key.' '
      let command_line .= '--set-tag='.key.'='.shellescape(value).' '
    endif
  endfor
  let command_line .= shellescape(a:filename)

  let output = system(command_line)
  if v:shell_error
    echoerr "There was an error executing the `flac` command: ".output
    return
  endif

  if new_filename != a:filename
    call rename(a:filename, new_filename)
    exe 'file '.fnameescape(new_filename)
    %delete _
    call id3#ReadFlac(new_filename)
  endif

  set nomodified
endfunction

function! s:Upcase(string)
  return substitute(a:string, '\l', '\u\0', 'g')
endfunction
