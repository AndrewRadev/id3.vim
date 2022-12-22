let s:id3_backend_mapping = {
      \ 'id3':     ['id3#id3#Read',     'id3#id3#Update'],
      \ 'id3v2':   ['id3#id3v2#Read',   'id3#id3v2#Update'],
      \ 'id3tool': ['id3#id3tool#Read', 'id3#id3tool#Update'],
      \ }

function! id3#ReadMp3(filename)
  if len(g:id3_mp3_backends) == 0
    return
  endif

  for backend in g:id3_mp3_backends
    if s:CheckCommand(backend)
      let [read_callback, update_callback] = s:id3_backend_mapping[backend]
      call call(read_callback, [a:filename])
      let b:update_callback = update_callback
      return
    endif
  endfor

  echoerr "No suitable command-line tool found. Please install one of: ".join(g:id3_mp3_backends, ', ')
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

  if !exists('b:update_callback')
    echoerr "This buffer doesn't look like it was opened by id3.vim, don't know how to persist tags"
    return
  endif

  call call(b:update_callback, [a:filename])
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
