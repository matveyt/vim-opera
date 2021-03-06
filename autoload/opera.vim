" Vim plugin to apply an Ex command to selection or g@ operator
" Maintainer:   matveyt
" Last Change:  2020 Nov 25
" License:      VIM License
" URL:          https://github.com/matveyt/vim-opera

let s:save_cpo = &cpo
set cpo&vim

" opera#block({cmd} [, {mods}])
" apply any :h :range command to the contents of unnamed register
" Note: the result will be put between `[ and `] marks
function! opera#block(cmd, ...) abort
    let l:mods = get(a:, 1, '')
    let l:last = line('$')
    let l:corr = &sel is# 'exclusive' ? 'l' : ''

    let l:regcontents = getreg('', 1, 1)
    let l:regtype = getregtype('')
    let l:vmode = l:regtype[0]
    if l:vmode is# "\<C-V>" && strchars(l:regcontents[-1], 1) != str2nr(l:regtype[1:])
        let l:corr = '$'
        if stridx(&ve, 'all') >= 0 || stridx(&ve, 'block') >= 0
            " trim trailing spaces
            " Note: this isn't always correct, yet this is the best we can do
            call map(l:regcontents, {_, v -> substitute(v, '\s\+$', '', '')})
        endif
    endif

    " append text & execute a:cmd & get result into reg 9
    call append(l:last, l:regcontents)
    try
        execute 'lockmarks' l:mods l:last..'+,$' a:cmd
        call setreg(9, getline(l:last + 1, '$'), l:vmode)
    finally
        call deletebufline('%', l:last + 1, '$')
    endtry

    " Note: l:corr must be the last, because it can fail
    execute 'normal! g`['..l:vmode..'g`]'..l:corr
    silent normal! "9p
endfunction

" opera#mapto({cmd} [, {mods}])
" automatic g@ operator mapping
function! opera#mapto(cmd, ...) abort
    let l:mods = get(a:, 1, '')
    let l:pos = stridx(l:mods, 'line')
    if l:pos < 0
        let l:linewise = v:false
    else
        let l:linewise = v:true
        let l:mods = strpart(l:mods, 0, l:pos) . strpart(l:mods, l:pos + 4)
    endif

    " Normal mode
    if mode() is# 'n'
        " our 'opfunc' is a closure to access local state
        function! s:opfunc(type) abort closure
            if a:type is# 'line' || l:linewise
                execute l:mods "'[,']" a:cmd
            else
                let [&sel, l:oldsel] = ['inclusive', &sel]
                silent normal! g`[vg`]"9y
                call opera#block(a:cmd, l:mods)
                let &sel = l:oldsel
            endif
        endfunction
        " set opfunc and return 'g@' to be used by map-<expr>
        let &opfunc = get(funcref('s:opfunc'), 'name')
        return 'g@'
    endif

    " Visual mode
    if mode() is# 'V' || l:linewise
        return printf("\<Esc>:%s'<,'>%s\<CR>", l:mods, a:cmd)
    else
        return printf("\"9y:call opera#block(%s, %s)\<CR>",
            \ string(a:cmd), string(l:mods))
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
