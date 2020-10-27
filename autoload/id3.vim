function! id3#ReadMp3(filename)
  if s:CheckCommand('id3')
    call s:ReadMp3Id3(a:filename)
  elseif s:CheckCommand('id3v2')
    call s:ReadMp3Id3v2(a:filename)
  elseif s:CheckCommand('id3tool')
    call s:ReadMp3Id3Tool(a:filename)
  else
    echoerr "No suitable command-line tool found. Install one of: id3, id3tool"
  endif
endfunction

function! s:ReadMp3Id3(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let format_string  = '%'.join(['_t', '_a', '_l', '_n', '_y', '_g', '_c'], '\n%')
  let command_output = system("id3 -q '".format_string."' ".filename)

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

function! s:ReadMp3Id3Tool(filename)
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
  let tags = map(tags, {key, value -> s:FormatID3ToolValue(value)})

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:    '.tags[1],
        \   'Artist:   '.tags[2],
        \   'Album:    '.tags[3],
        \   'Track No: '.tags[4],
        \   'Year:     '.tags[5],
        \   'Genre:    '.tags[6],
        \ ])
  $delete _
  call cursor(1, 1)

  set filetype=audio.mp3
endfunction

function! s:ReadMp3Id3v2(filename)
  if !filereadable(a:filename)
    echoerr "File does not exist, can't open MP3 metadata: ".a:filename
    return
  endif

  let filename       = shellescape(a:filename)
  let command_output = system("id3v2 -R ".filename)

  if v:shell_error
    echoerr "There was an error executing the `id3v2` command: ".command_output
    return
  endif

  let tags = split(command_output, "\n")

  call append(0, [
        \   'File: '.a:filename,
        \   repeat('=', len('File: '.a:filename)),
        \   '',
        \   'Title:    '.s:GetV2Tag(tags, "TIT2"),
        \   'Artist:   '.s:GetV2Tag(tags, "TPE1"),
        \   'Album:    '.s:GetV2Tag(tags, "TALB"),
        \   'Track No: '.s:GetV2Tag(tags, "TRCK"),
        \   'Year:     '.s:GetV2Tag(tags, "TYER"),
        \   'Genre:    '.s:GetV2Tag(tags, "TCON"),
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
  let saved_view = winsaveview()
  if s:CheckCommand('id3')
    call s:UpdateMp3Id3(a:filename)
  elseif s:CheckCommand('id3v2')
    call s:UpdateMp3Id3v2(a:filename)
  elseif s:CheckCommand('id3tool')
    call s:UpdateMp3Id3Tool(a:filename)
  else
    echoerr "No suitable command-line tool found. Install one of: id3, id3v2, id3tool"
  endif
endfunction

function! s:UpdateMp3Id3(filename)
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

  call winrestview(saved_view)
  set nomodified
endfunction

function! s:UpdateMp3Id3Tool(filename)
  let new_filename = s:FindTagValue('File')

  let tags   = {}
  let tags.t = s:FindTagValue('Title')
  let tags.r = s:FindTagValue('Artist')
  let tags.a = s:FindTagValue('Album')
  let tags.c = s:FindTagValue('Track No')
  let tags.y = s:FindTagValue('Year')
  let tags.G = s:FindTagValue('Genre')

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

function! s:UpdateMp3Id3v2(filename)
  let new_filename = s:FindTagValue('File')

  let tags   = {}
  let tags.t = s:FindTagValue('Title')
  let tags.a = s:FindTagValue('Artist')
  let tags.A = s:FindTagValue('Album')
  let tags.T = s:FindTagValue('Track No')
  let tags.y = s:FindTagValue('Year')
  " Can only update genre through the code in id3v2
  let tags.g = matchstr(s:FindTagValue('Genre'), '([0-9]\{1,3})')

  let command_line = 'id3v2 '
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

function! s:CheckCommand(command)
  call system('which '.a:command)
  if v:shell_error == 0
    return 1
  else
    return 0
  endif
endfunction

function! s:FindTagValue(tag_name)
  let tag_pattern = '^'.a:tag_name.':\s*\(.*\)$'
  let tag_line    = search(tag_pattern, 'n')

  if tag_line <= 0
    return ''
  endif

  return substitute(getline(tag_line), tag_pattern, '\1', '')
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

function! s:GetV2Tag(tag_list, tag_value) 
  let required_tag = filter(copy(a:tag_list), {key, value -> s:MatchTag(value, a:tag_value) != ""})
  if empty(required_tag)
    echoerr "Could not find a tag matching ".a:tag_value
  endif
  return trim(strpart(required_tag[0], stridx(required_tag[0], ":") + 1))
endfunction

function! s:MatchTag(value, expected_tag)
  let split_value = split(a:value, ":")
  if split_value[0] == a:expected_tag
    return trim(split_value[1])
  else
    return ""
  endif
endfunction

function! s:Upcase(string)
  return substitute(a:string, '\l', '\u\0', 'g')
endfunction
