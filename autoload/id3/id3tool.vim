function! id3#id3tool#Read(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let command_output = system("id3tool ".filename)

  if v:shell_error
    echoerr "There was an error executing the `id3tool` command: ".command_output
    return
  endif

  let tags = split(command_output, "\n")

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:    '.s:ParseTag(tags, 'Song Title'),
        \   'Artist:   '.s:ParseTag(tags, 'Artist'),
        \   'Album:    '.s:ParseTag(tags, 'Album'),
        \   'Track No: '.s:ParseTag(tags, 'Track'),
        \   'Year:     '.s:ParseTag(tags, 'Year'),
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=audio.mp3
endfunction

function! id3#id3tool#Update(filename)
  let new_filename = id3#utils#FindTagValue('File')

  let tags   = {}
  let tags.t = id3#utils#FindTagValue('Title')
  let tags.r = id3#utils#FindTagValue('Artist')
  let tags.a = id3#utils#FindTagValue('Album')
  let tags.c = id3#utils#FindTagValue('Track No')
  let tags.y = id3#utils#FindTagValue('Year')

  let command_line = 'id3tool '
  for [key, value] in items(tags)
    let command_line .= '-'.key.' '.shellescape(value).' '
  endfor
  let command_line .= shellescape(a:filename)

  let output = system(command_line)
  if v:shell_error
    echoerr "There was an error executing the `id3tool` command: ".output
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

function! s:FormatID3ToolValue(string)
  let contains_colon = stridx(a:string, ":")
  if contains_colon == -1
    return trim(a:string)
  else
    " Remove the genre code returned with the genre string, as only one of
    " those can be used when updating the values with id3tool
    let string_value = a:string
    if match(string_value, "Genre:") == 0
      let string_value = substitute(string_value, '\s(0x[0-9]\{2})', "", "g")
    endif

    return trim(strpart(string_value, contains_colon + 1))
  endif
endfunction

function! s:ParseTag(tag_list, tag_value)
  let required_tag = filter(
        \   copy(a:tag_list),
        \   {key, value -> s:MatchTag(value, a:tag_value) != ""}
        \ )
  if empty(required_tag)
    return ""
  endif
  return trim(strpart(required_tag[0], stridx(required_tag[0], ":") + 1))
endfunction

function! s:MatchTag(value, expected_tag)
  let split_value = split(a:value, ":")
  if empty(split_value)
    return ""
  endif

  if split_value[0] == a:expected_tag
    return trim(split_value[1])
  else
    return ""
  endif
endfunction
