### Description

This plugin allows to use any `:h :range` commands with non-linewise motions and
selections.

#### Download and Install

```
$ git clone https://github.com/matveyt/vim-opera ~/.vim/pack/manual/start/vim-opera
```

### Usage

    " map gs{motion} / {Visual}gs / gss to sort selection
    nnoremap <expr><silent>gs opera#mapto('sort')
    xnoremap <expr><silent>gs opera#mapto('sort')
    nnoremap <silent>gss :sort<CR>

    " apply :sort to arbitrary selection
    :'<,'>B sort

See `:help opera.txt`.
