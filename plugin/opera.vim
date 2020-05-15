" Vim plugin to apply an Ex command to selection or g@ operator
" Maintainer:   matveyt
" Last Change:  2020 May 15
" License:      VIM License
" URL:          https://github.com/matveyt/vim-opera

if exists('g:loaded_opera')
    finish
endif
let g:loaded_opera = 1

let s:save_cpo = &cpo
set cpo&vim

command! -range -nargs=1 -complete=command B
    \   if visualmode() is# 'V'
    \ |     execute <q-mods>..<line1>..','..<line2>..<q-args>
    \ | else
    \ |     execute 'silent normal! gv"9y'
    \ |     call opera#block(<q-args>, <q-mods>)
    \ | endif

let &cpo = s:save_cpo
unlet s:save_cpo
