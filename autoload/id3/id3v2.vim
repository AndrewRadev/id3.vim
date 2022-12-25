function! id3#id3v2#Read(command, filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let command_output = system(a:command . ' -R ' . filename)

  if v:shell_error
    echoerr "There was an error executing the `id3v2` command: ".command_output
    return
  endif

  let tags = split(command_output, "\n")

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:    '.s:GetV2Tag(tags, "TIT2", "TT2"),
        \   'Artist:   '.s:GetV2Tag(tags, "TPE1", "TP1"),
        \   'Album:    '.s:GetV2Tag(tags, "TALB", "TAL"),
        \   'Track No: '.s:GetV2Tag(tags, "TRCK", "TRK"),
        \   'Year:     '.s:GetV2Tag(tags, "TYER", "TYE"),
        \   'Genre:    '.s:GetV2Tag(tags, "TCON", "TCO"),
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=audio.mp3
endfunction

function! id3#id3v2#Update(command, filename)
  let new_filename = id3#utils#FindTagValue('File')

  let tags   = {}
  let tags.t = id3#utils#FindTagValue('Title')
  let tags.a = id3#utils#FindTagValue('Artist')
  let tags.A = id3#utils#FindTagValue('Album')
  let tags.T = id3#utils#FindTagValue('Track No')
  let tags.y = id3#utils#FindTagValue('Year')
  " Can only update genre through the code in id3v2
  let tags.g = matchstr(id3#utils#FindTagValue('Genre'), '([0-9]\{1,3})')

  let command_line = a:command . ' '
  for [key, value] in items(tags)
    let command_line .= '-'.key.' '.shellescape(value).' '
  endfor
  let command_line .= shellescape(a:filename)

  let output = system(command_line)
  if v:shell_error
    echoerr "There was an error executing the `id3v2` command: ".output
    return
  endif

  if new_filename != a:filename
    call rename(a:filename, new_filename)
    exe 'file '.fnameescape(new_filename)
  endif
  " Call read again to display genre updates
  %delete _
  call id3#id3v2#Read(a:command, new_filename)

  set nomodified
endfunction

function! s:GetV2Tag(tag_list, tag_value, old_tag_value)
  let required_tag = filter(
        \   copy(a:tag_list),
        \   {key, value -> s:MatchTag(value, a:tag_value) != "" || s:MatchTag(value, a:old_tag_value) != ""}
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
