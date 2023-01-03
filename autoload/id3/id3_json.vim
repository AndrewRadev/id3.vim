function! id3#id3_json#Read(command, filename) abort
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let command_output = system(a:command . ' ' . filename)
  if v:shell_error
    echoerr "There was an error executing the `id3-json` command: " . command_output
    return
  endif

  let json = json_decode(command_output)
  if has_key(json, "error")
    echoerr "There was an error executing the `id3-json` command: " . json['error']
    return
  endif

  let tags = s:NullToString(json.data)
  let tag_version = json.version

  let file_line = 'File: '.a:filename
  let version_line = 'Version: '.tag_version

  let lines = [
        \   file_line,
        \   repeat('=', strchars(file_line)),
        \   '',
        \   'Title:    '.get(tags, 'title', ''),
        \   'Artist:   '.get(tags, 'artist', ''),
        \   'Album:    '.get(tags, 'album', ''),
        \   'Track No: '.get(tags, 'track', ''),
        \ ]
  if has_key(tags, 'year')
    call extend(lines, [
          \   'Year:     '.get(tags, 'year', ''),
          \ ])
  endif
  if has_key(tags, 'date')
    call extend(lines, [
          \   'Date:     '.get(tags, 'date', ''),
          \ ])
  endif
  call extend(lines, [
        \   'Genre:    '.get(tags, 'genre', ''),
        \   'Comment:  '.get(tags, 'comment', ''),
        \   '',
        \   repeat('=', strchars(version_line)),
        \   version_line,
        \ ])

  call append(0, lines)
  $delete _
  call cursor(1, 1)

  set filetype=audio.mp3
endfunction

function! id3#id3_json#Update(command, filename) abort
  let new_filename = id3#utils#FindTagValue('File')
  let tags = {}

  let tags.title   = id3#utils#FindTagValue('Title')
  let tags.artist  = id3#utils#FindTagValue('Artist')
  let tags.album   = id3#utils#FindTagValue('Album')
  let tags.track   = id3#utils#FindTagValue('Track No')
  let tags.year    = id3#utils#FindTagValue('Year')
  let tags.genre   = id3#utils#FindTagValue('Genre')
  let tags.comment = id3#utils#FindTagValue('Comment')

  let tags = s:StringToNull(tags)

  let command_line = a:command . ' --write ' . shellescape(a:filename)
  let output = system(command_line, json_encode(tags))
  if v:shell_error
    echoerr "There was an error executing the `id3-json` command: ".output
    return
  endif

  if new_filename != a:filename
    call rename(a:filename, new_filename)
    exe 'file ' . fnameescape(new_filename)
    %delete _
    call id3#ReadMp3(new_filename)
  endif

  set nomodified
endfunction

function! s:NullToString(json)
  for key in keys(a:json)
    if a:json[key] == v:null
      let a:json[key] = ''
    endif
  endfor

  return a:json
endfunction

function! s:StringToNull(data)
  for key in keys(a:data)
    if a:data[key] == ''
      let a:data[key] = v:null
    endif
  endfor

  return a:data
endfunction
