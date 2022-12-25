let s:id3_backend_mapping = {
      \ 'id3-json': ['id3#id3_json#Read', 'id3#id3_json#Update'],
      \ 'id3':      ['id3#id3#Read',      'id3#id3#Update'],
      \ 'id3v2':    ['id3#id3v2#Read',    'id3#id3v2#Update'],
      \ 'id3tool':  ['id3#id3tool#Read',  'id3#id3tool#Update'],
      \ }

function! id3#ReadMp3(filename)
  if len(g:id3_mp3_backends) == 0
    return
  endif

  for backend in g:id3_mp3_backends
    let command = s:FindCommand(backend)
    if command != ''
      let [read_callback, update_callback] = s:id3_backend_mapping[backend]
      call call(read_callback, [command, a:filename])
      let b:update_callback = [update_callback, command]
      return
    endif
  endfor

  echoerr "No suitable command-line tool found. Please install one of: ".join(g:id3_mp3_backends, ', ')
endfunction

function! id3#ReadFlac(filename)
  let command = s:FindCommand('metaflac')
  if command != ''
    call id3#flac#Read(command, a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `metaflac`"
  endif
endfunction

function! id3#ReadOpus(filename)
  let command = s:FindCommand('opustags')
  if command != ''
    call id3#opus#Read(command, a:filename)
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

  let [callback, command] = b:update_callback

  call call(callback, [command, a:filename])
  call winrestview(saved_view)
endfunction

function! id3#UpdateFlac(filename)
  let saved_view = winsaveview()

  let command = s:FindCommand('metaflac')
  if command != ''
    call id3#flac#Update(command, a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `metaflac`"
  endif

  call winrestview(saved_view)
endfunction

function! id3#UpdateOpus(filename)
  let saved_view = winsaveview()

  let command = s:FindCommand('opustags')
  if command != ''
    call id3#opus#Update(command, a:filename)
  else
    echoerr "No suitable command-line tool found. Please install `opustags`"
  endif

  call winrestview(saved_view)
endfunction

function! s:FindCommand(command)
  if g:id3_executable_directory != ''
    if isabsolutepath(g:id3_executable_directory)
      let local_file = g:id3_executable_directory.'/'.a:command
    else
      let local_file = findfile(g:id3_executable_directory.'/'.a:command, escape(&runtimepath, ' '))
    endif

    if local_file != '' && filereadable(local_file)
      return local_file
    endif
  endif

  if executable(a:command)
    return a:command
  else
    return ''
  endif
endfunction
