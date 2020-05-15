" Vim plugin to apply an Ex command to selection or g@ operator
" Maintainer:   matveyt
" Last Change:  2020 May 15
" License:      VIM License
" URL:          https://github.com/matveyt/vim-opera

" opera#block({cmd} [, {mods}])
" apply any :h :range command to text selection
" Note: {cmd} is applied to the contents of unnamed register;
" the result replaces text between `[ and `]
function! opera#block(cmd, ...) abort
    let l:start = getpos("'[")
    let l:end = getpos("']")
    let l:last = line('$')
    let l:corr = &selection is# 'exclusive' ? 'l' : ''

    let l:regcontents = getreg('', 1, 1)
    let l:regtype = getregtype('')
    let l:vmode = l:regtype[0]
    if l:vmode is# "\<C-V>" && strchars(l:regcontents[-1], 1) != str2nr(l:regtype[1:])
        let l:corr = '$'
        if stridx(&ve, 'all') >= 0 || stridx(&ve, 'block') >= 0
            " trim trailing spaces
            call map(l:regcontents, {_, v -> substitute(v, '\s\+$', '', '')})
        endif
    endif

    call append(l:last, l:regcontents)
    try
        execute get(a:, 1, '') l:last..'+,$' a:cmd
        call setreg(9, getline(l:last + 1, '$'), l:vmode)
    finally
        call deletebufline('%', l:last + 1, '$')
    endtry

    call setpos("'[", l:start)
    call setpos("']", l:end)
    " Note: l:corr must be the last, because it can fail
    execute 'normal! g`['..l:vmode..'g`]'..l:corr
    silent normal! "9p
endfunction

" opera#mapto({cmd} [, {mods}])
" automatic g@ operator mapping
function! opera#mapto(cmd, ...) abort
    let l:mods = get(a:, 1, '')
    let l:linewise = stridx(l:mods, 'bro') >= 0

    " Normal mode
    if mode() is# 'n'
        " our 'opfunc' is a closure to access local state
        function! s:opfunc(type) abort closure
            if a:type is# 'line' || l:linewise
                execute l:mods "'[,']" a:cmd
            else
                normal! g`[vg`]"9y
                call opera#block(a:cmd, l:mods)
            endif
        endfunction
        " set opfunc and return 'g@' to be used by map-<expr>
        let &opfunc = get(funcref('s:opfunc'), 'name')
        return 'g@'
    endif

    " Visual mode
    if mode() is# 'V' || l:linewise
        return printf(":\<C-U>%s'<,'>%s\<CR>", l:mods, a:cmd)
    else
        return printf("\"9y:call opera#block(%s, %s)\<CR>",
            \ string(a:cmd), string(l:mods))
    endif
endfunction
