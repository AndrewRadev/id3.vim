if exists('g:loaded_id3') || &cp
  finish
endif

let g:loaded_id3 = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

autocmd BufReadCmd *.mp3  call id3#ReadMp3(expand('<afile>'))
autocmd BufWriteCmd *.mp3 call id3#UpdateMp3(expand('<afile>'))

let &cpo = s:keepcpo
unlet s:keepcpo
