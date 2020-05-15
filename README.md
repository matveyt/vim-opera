### Description

This plugin allows to use any `:h :range` commands with non-linewise motions and
selections.

### Download and Install

Use whatever plugin manager to pull the master branch.

### Usage

    " map gs{motion} / {Visual}gs / gss to sort selection
    nnoremap <expr><silent>gs opera#mapto('sort')
    xnoremap <expr><silent>gs opera#mapto('sort')
    nnoremap <silent>gss :sort<CR>

    " apply :sort to arbitrary selection
    :'<,'>B sort

Read `:help opera`.

### License
Distributed under the same terms as Vim itself. See `:help license`.
