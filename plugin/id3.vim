if exists('g:loaded_id3') || &cp
  finish
endif

let g:loaded_id3 = '0.1.0' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:id3_mp3_backends')
  let g:id3_mp3_backends = ['id3-json', 'id3', 'id3v2', 'id3tool']
endif

autocmd BufReadCmd *.mp3  call id3#ReadMp3(expand('<afile>'))
autocmd BufWriteCmd *.mp3 call id3#UpdateMp3(expand('<afile>'))

autocmd BufReadCmd *.flac  call id3#ReadFlac(expand('<afile>'))
autocmd BufWriteCmd *.flac call id3#UpdateFlac(expand('<afile>'))

autocmd BufReadCmd *.opus  call id3#ReadOpus(expand('<afile>'))
autocmd BufWriteCmd *.opus call id3#UpdateOpus(expand('<afile>'))

let &cpo = s:keepcpo
unlet s:keepcpo
