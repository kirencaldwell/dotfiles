set number
filetype plugin indent on
set expandtab
set tabstop=2
set shiftwidth=2

" plugin section
call plug#begin()

" fzf
Plug 'junegunn/fzf'

" Initialize plugin system
call plug#end()

" Ignore bazel out folders
set wildignore+=*/bazel-*

" Display all matching files when we tab complete
set wildmenu

"move between windows faster
noremap <C-J> <C-W><C-J>
noremap <C-K> <C-W><C-K>
noremap <C-L> <C-W><C-L>
noremap <C-H> <C-W><C-H>

" open matching header or cpp file file
function! SwappedExtension()
    let [rest, ext] = [expand('%:r'), expand('%:e')]
    if ext ==? 'h'
        let ext = 'cpp'
    elseif ext ==? 'cpp'
        let ext = 'h'
    elseif ext ==? 'c'
        let ext = 'h'
    endif
    return rest . '.' . ext
endfunction
:nnoremap <C-h> :vs <C-r>=SwappedExtension()<CR><CR>


" open file under cursor in new tab
map <t-f> <C-w>f

" :Q and :W also write and close
command! Q q
command! W w

" search options
set incsearch
set hlsearch
nnoremap <CR> :noh<CR><CR>

highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
colorscheme desert
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10
