function! id3#ReadMp3(filename)
  if s:CheckCommand('id3')
    call id3#id3#Read(a:filename)
  elseif s:CheckCommand('id3v2')
    call id3#id3v2#Read(a:filename)
  elseif s:CheckCommand('id3tool')
    call id3#id3tool#Read(a:filename)
  else
    echoerr "No suitable command-line tool found. Please install one of: `id3`, `id3v2`, `id3tool`"
  endif
endfunction

function! id3#ReadFlac(filename)
  if s:CheckCommand('metaflac')
    call id3#flac#Read(a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `metaflac`"
  endif
endfunction

function! id3#ReadOpus(filename)
  if s:CheckCommand('opustags')
    call id3#opus#Read(a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `opustags`"
  endif
endfunction

function! id3#UpdateMp3(filename)
  let saved_view = winsaveview()

  if s:CheckCommand('id3')
    call id3#id3#Update(a:filename)
  elseif s:CheckCommand('id3v2')
    call id3#id3v2#Update(a:filename)
  elseif s:CheckCommand('id3tool')
    call id3#id3tool#Update(a:filename)
  else
    echoerr "No suitable command-line tool found. Install one of: id3, id3v2, id3tool"
  endif

  call winrestview(saved_view)
endfunction

function! id3#UpdateFlac(filename)
  let saved_view = winsaveview()

  if s:CheckCommand('metaflac')
    call id3#flac#Update(a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `metaflac`"
  endif

  call winrestview(saved_view)
endfunction

function! id3#UpdateOpus(filename)
  let saved_view = winsaveview()

  if s:CheckCommand('opustags')
    call id3#opus#Update(a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `opustags`"
  endif

  call winrestview(saved_view)
endfunction

function! s:CheckCommand(command)
  call system('which '.a:command)
  if v:shell_error == 0
    return 1
  else
    return 0
  endif
endfunction
