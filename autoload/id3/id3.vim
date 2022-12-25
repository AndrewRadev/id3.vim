function! id3#id3#Read(command, filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let format_string  = '%'.join(['_t', '_a', '_l', '_n', '_y', '_g', '_c'], '\n%')
  let command_output = system(a:command . " -q '".format_string."' ".filename)

  if v:shell_error
    echoerr "There was an error executing the `id3` command: ".command_output
    return
  endif

  let tags = split(command_output, "\n")
  let tags = map(tags, 'v:val != "<empty>" ? v:val : ""')
  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', strchars('File: '.a:filename)),
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

function! id3#id3#Update(command, filename)
  let new_filename = id3#utils#FindTagValue('File')

  let tags   = {}
  let tags.t = id3#utils#FindTagValue('Title')
  let tags.a = id3#utils#FindTagValue('Artist')
  let tags.l = id3#utils#FindTagValue('Album')
  let tags.n = id3#utils#FindTagValue('Track No')
  let tags.y = id3#utils#FindTagValue('Year')
  let tags.g = id3#utils#FindTagValue('Genre')
  let tags.c = id3#utils#FindTagValue('Comment')

  let command_line = a:command . ' '
  for [key, value] in items(tags)
    let command_line .= '-'.key.' '.shellescape(value).' '
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
