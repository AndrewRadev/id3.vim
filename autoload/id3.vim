function! id3#ReadMp3(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let format_string  = '%'.join(['t', 'a', 'l', 'n', 'y', 'g', 'c'], '\n%')
  let command_output = system("id3 -q '".format_string."' ".filename)

  if v:shell_error
    echoerr "There was an error executing the `id3` command: ".command_output
    return
  endif

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

  set filetype=audio.mp3
endfunction

function! id3#ReadFlac(filename)
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

function! id3#UpdateMp3(filename)
  let new_filename = s:FindTagValue('File')

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
    echoerr "There was an error executing the `id3` command: ".output
    return
  endif

  if new_filename != a:filename
    call rename(a:filename, new_filename)
    exe 'file '.fnameescape(new_filename)
    %delete _
    call id3#ReadMp3(new_filename)
  endif

  set nomodified
endfunction

function! id3#UpdateFlac(filename)
  let new_filename = s:FindTagValue('File')

  let tags             = {}
  let tags.TITLE       = s:FindTagValue('Title')
  let tags.ARTIST      = s:FindTagValue('Artist')
  let tags.ALBUM       = s:FindTagValue('Album')
  let tags.TRACKNUMBER = s:FindTagValue('Track No')
  let tags.DATE        = s:FindTagValue('Date')
  let tags.GENRE       = s:FindTagValue('Genre')
  let tags.DESCRIPTION = s:FindTagValue('Description')

  let command_line = 'metaflac '
  for [key, value] in items(tags)
    if value != ''
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

function! s:FindTagValue(tag_name)
  let tag_pattern = '^'.a:tag_name.':\s*\(.*\)$'
  let tag_line    = search(tag_pattern, 'n')

  if tag_line <= 0
    return ''
  endif

  return substitute(getline(tag_line), tag_pattern, '\1', '')
endfunction

function! s:Upcase(string)
  return substitute(a:string, '\l', '\u\0', 'g')
endfunction
