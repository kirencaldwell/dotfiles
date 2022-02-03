set number
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab

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
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
