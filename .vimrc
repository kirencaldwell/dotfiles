""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vimrc Examples
"
" This file contains a collection of snippets demonstrating various ways to
" configure vim. Take as much or as little as you like to build the editor
" experience you want.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set the runtime path to include Vundle and initialize.
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim' " Manage Vundle with Vundle

" Add your list of plugins here.
Plugin 'Lokaltog/vim-easymotion' " Easily navigate to symbols by prefix
" Plugin 'Valloric/YouCompleteMe' " Autocompletion and code fixes
Plugin 'Xuyuanp/nerdtree-git-plugin' " Git integration with nerdtree
Plugin 'airblade/vim-gitgutter' " Show git diff in the gutter
" Plugin 'altercation/vim-colors-solarized' " Solarized color theme for vim
" Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy finder
Plugin 'editorconfig/editorconfig-vim' " Editorconfig integration
Plugin 'mhinz/vim-grepper' " Sync grep within vim
Plugin 'octol/vim-cpp-enhanced-highlight' " Better C++ syntax highlighting
" Plugin 'powerline/fonts' " Pre-patched and adjusted fonts for status line
" Plugin 'qpkorr/vim-bufkill' " Close buffers without closing windows or splits.
Plugin 'rhysd/vim-clang-format' " Auto-format C++ files
Plugin 'scrooloose/nerdtree' " File navigation
Plugin 'tpope/vim-abolish' " Assorted word-munging utilities
Plugin 'tpope/vim-commentary' " Easy (un)commenting of code blocks
Plugin 'tpope/vim-fugitive' " Integrated git commands
" Plugin 'tpope/vim-obsession' " Intelligent and automatic session management
Plugin 'tpope/vim-repeat' " Better command classification for `.`
" Plugin 'tpope/vim-surround' " Easily manipulate surrounding symbols
" Plugin 'vim-airline/vim-airline' " Better status line
" Plugin 'vim-airline/vim-airline-themes' " Color theme support for airline
" Plugin 'vim-syntastic/syntastic' " Syntax checking for several common languages
Plugin 'dense-analysis/ale'
Plugin 'vim-utils/vim-all' " Full-buffer text objects
Plugin 'vim-utils/vim-man' " Open man pages in vim
Plugin 'vim-utils/vim-space' " Text objects with <Space> as the delimiter
Plugin 'vim-utils/vim-troll-stopper' " Convert elusive unicode characters to ASCII

" All of your Plugins must be added before the following line.
call vundle#end()

call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
call plug#end()

filetype plugin indent on



"" Airline

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:airline#extensions#tabline#enabled = 1
"let g:airline_theme='solarized'
"let g:airline_solarized_bg='dark'
"let g:airline_powerline_fonts = 1

" ClangFormat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:clang_format#command='clang-format-3.6'
let g:clang_format#detect_style_file=1
autocmd FileType c,cpp,objc let g:clang_format#auto_format=0

" CppEnhancedHighlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight=1
let g:cpp_experimental_simple_template_highlight=1
let g:cpp_concepts_highlight=1

" set runtimepath^=~/.vim/bundle/ctrlp.vim
" let g:ctrlp_max_files=20000

" EditorConfig
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EditorConfig_exclude_patterns=['fugitive://.*']

" GitGutter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_diff_args='--patience' " Add flags to git diff.
let g:gitgutter_eager=0 " Only redraw gutter on buffer save / open.

" Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Commands:
"     Errors               pop up location list and display errors
"     SyntasticToggleMode  toggles between active and passive mode
"     SyntasticCheck       forces a syntax check in passive mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_check_on_open=1 " Check for syntax errors on file open.
let g:syntastic_echo_current_error=1 " Echo errors to the command window.
let g:syntastic_enable_signs=1 " Mark lines with errors and warnings.
let g:syntastic_enable_balloons=0 " Do not open error balloons over erroneous lines.
let g:syntastic_cpp_check_header=1 " YCM will provide context for C++ files.
let g:syntastic_c_check_header=1 " Same for C files.

" Ale
let b:ale_fixers = ['prettier', 'eslint']

" YouCompleteMe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ycm_global_ycm_extra_conf='~/driving/experimental/bryce/config/ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files=1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup FileTypeAssociation
   autocmd!
   autocmd BufNewFile,BufRead *.impl,*.inl set filetype=cpp
   autocmd BufNewFile,BufRead *.launch set filetype=xml
   autocmd BufNewFile,BufRead *.make set filetype=make
   autocmd BufNewFile,BufRead WORKSPACE,BUILD,BUILD.*,*.bzl,*.bazel set filetype=python
augroup END

" Resize splits on window resize.
augroup AutoResizeSplits
   autocmd!
   autocmd VimResized * exe "normal! \<c-w>="
augroup END

" Start NERDTree if vim is started without parameters.
augroup OpenCloseNERDTree
   autocmd!
   " Auto-open NERDTree when vim is started with no arguments.
   autocmd VimEnter * if argc() == 0 | NERDTree | endif
   " Auto-close NERDTree when no other buffers are left.
   autocmd StdinReadPre * let s:std_in=1
   autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration customization
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
behave xterm                    " Always use Linux keybindings (even on Windows).
syntax enable                   " Enable syntax highlighting.
set autowrite                   " Write before executing the 'make' command.
set backspace=indent,eol,start  " Allow <BS> to go over indents, eol, and start of insert.
" set colorcolumn=80              " Highlight the 80th column.
set cpoptions+=$                " Show dollar sign at end of text to be changed.
set cursorline                  " Highlight current line.
set dictionary+=~/.vim/dictionary/english-freq
set encoding=utf-8              " Set encoding to utf-8.
set expandtab                   " Expand tabs into spaces.
set fileencoding=utf-8          " Set fileencoding to utf-8.
set foldcolumn=1                " Add N columns to show fold levels and boundaries.
set foldmethod=indent           " Set fold method (manual,indent,expr,syntax,diff,marker).
set hidden                      " Use hidden buffers so unsaved buffers can go to the background.
set history=500                 " Set number of lines for vim to remember.
set hlsearch                    " Highlight all search matches.
set ignorecase                  " Ignore case in regular expressions.
set incsearch                   " Immediately highlight search matches.
set laststatus=2                " Show status line even where there is only one window.
set lazyredraw                  " Redraw faster.
set linespace=0                 " Adjust relative line height.
set list                        " Enable listchars for undesireable whitespace and non-visible wrapped text.
set listchars=tab:➤-,trail:·,extends:»,precedes:«
set modeline                    " Check files for a modeline to apply config settings.
set nocompatible                " No compatibility with vi.
set noerrorbells                " No beeps on errors.
set nofoldenable                " Do not open file folded.
set noswapfile                  " Don't use swap files.
set number                      " Display line numbers.
set path=,,.,**,/usr/include,/usr/local/include
set scrolloff=5                 " Keep min of N lines above/below cursor.
set shellslash                  " Use forward slashes regardless of OS.
set shiftwidth=2                " Auto-indent N spaces each indent level.
set showcmd                     " Show partial commands in the status line.
set showmatch                   " Show matching () {} etc..
set showmode                    " Show current editor mode (insert, visual, replace, etc).
set sidescrolloff=10            " Keep min of N columns right/left cursor.
set smartcase                   " Searches are case-sensitive only if caps used.
set smartindent                 " Maintains most indentation and adds extra level when nesting.
set smarttab                    " Tabs and backspaces at the start of a line indent the line one level.
set softtabstop=2               " Using a TAB inserts N spaces.
set splitright splitbelow       " Open splits below and to the right.
set synmaxcol=2000              " Only matches syntax on first N columns of each line.
set tabstop=2                   " TABs expand to N spaces.
set textwidth=80                " Hard wrap at N characters.
set ttyfast                     " Smoother redrawing.
set viminfo='20,\"500,%         " Adjust viminfo contents.
set virtualedit=block           " Allow the cursor to move to columns without text.
set wildignore=*.sw?,*.pyc      " Ignore generated files in the source tree.
set wildignorecase              " Tab completion is case-insensitive.
set wildmenu                    " Tab completion navigable menu is enabled.
set wildmode=list:longest,full  " Tab completion lists matches, then opens wildmenu on next <Tab>.
set wrap                        " Soft wrap lines.
set wrapscan                    " Searching wraps to start of file when end is reached.

" Completion settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Options:
"     .        scan the current buffer ('wrapscan' is ignored)
"     w        scan buffers from other windows
"     b        scan other loaded buffers that are in the buffer list
"     u        scan the unloaded buffers that are in the buffer list
"     U        scan the buffers that are not in the buffer list
"     k        scan the files given with the 'dictionary' option
"     kspell   use the currently active spell checking |spell|
"     k{dict}  scan the file {dict}
"     s        scan the files given with the 'thesaurus' option
"     s{tsr}   scan the file {tsr}
"     i        scan current and included files
"     d        scan current and included files for defined name or macro |i_CTRL-X_CTRL-D|
"     t        tag completion
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set complete=.,w,b,u,t,i
autocmd FileType markdown,gitcommit,text setlocal complete+=k spell

" Text formatting settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Options:
"     t  Auto-wrap text using textwidth. (default)
"     c  Auto-wrap comments; insert comment leader. (default)
"     q  Allow formatting of comments with "gq". (default)
"     r  Insert comment leader after hitting <Enter>.
"     o  Insert comment leader after hitting 'o' or 'O' in command mode.
"     n  Auto-format lists, wrapping to text after the list bullet char.
"     l  Don't auto-wrap if a line is already longer than textwidth.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set formatoptions=tcqronl

" Enable mouse scrolling in selected modes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Options:
"     a  All
"     c  Command
"     i  Insert
"     n  Normal
"     v  Visual
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=

" Color theme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256                  " Use as many colors as your terminal supports.
set background=dark           " Most people prefer a dark background.
silent! colorscheme solarized " Must be silent so Vundle does not fail when installing for the first time.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Normal mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap du dt_x


" Make y behave like all other capitals (yank to end of line).
nnoremap Y y$

" No one ever intends to enter ex-mode. Make it harder by rebinding to QQ.
nnoremap Q <nop>
nnoremap QQ Q


" Toggles for search highlight, line numbers, paste mode, and word wrap.
nnoremap <Leader>h :set invhlsearch<CR>
nnoremap <Leader>n :set invnumber<CR>
nnoremap <Leader>p :set invpaste<CR>
nnoremap <Leader>w :set invwrap<CR>

" Toggle NERDTree.
nnoremap <Leader>t :NERDTreeToggle<CR>

" Run clang-format on open file.
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>f :ClangFormat<CR>
nmap <Leader>F :ClangFormatAutoToggle<CR>

" Run grepper on motion.
nmap gs <plug>(GrepperOperator)

" Visual mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Run clang-format on visual selection.
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>f :ClangFormat<CR>

" Run grepper on visual selection.
xmap gs <plug>(GrepperOperator)

" Insert mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" C-hjkl navigation in insert mode.
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>


" Ignore bazel out folders
set wildignore+=*/bazel-*

" Display all matching files when we tab complete
set wildmenu

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

" open nearest BUILD file, moves up the path until it finds a BUILD file
function! FindBuild()
    let req = '%:h'
    let file_loc = expand(req)
    let build_loc = file_loc . '/BUILD'
    let kMaxIter = 10
    let iter = 0
    while (iter <= kMaxIter) && (!filereadable(build_loc))
      let req = req . ':h'
      let file_loc = expand(req)
      let build_loc = file_loc . '/BUILD'
      let iter += 1
    endwhile
    return build_loc
endfunction
:nnoremap <C-b> :vs <C-r>=FindBuild()<CR><CR>



" open file under cursor in new tab
map <t-f> <C-w>f

" :Q and :W also write and close
command! Q q
command! W w

" search options
set incsearch
set hlsearch
nnoremap <CR> :noh<CR><CR>

syntax on

highlight Cursor guifg=yellow guibg=black
highlight iCursor guifg=yellow guibg=steelblue
colorscheme default
hi CursorLine term=bold cterm=bold guibg=white
hi StatusLine   ctermfg=15  guifg=#ffffff ctermbg=239 guibg=#4e4e4e cterm=bold gui=bold
hi StatusLineNC ctermfg=249 guifg=#b2b2b2 ctermbg=237 guibg=#3a3a3a cterm=none gui=bold
set ruler
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10
hi Visual term=bold cterm=bold ctermbg=Yellow guibg=Grey

set autoread
au FocusGained,BufEnter * :checktime

" Set leader key (must be set before any <leader> mappings)
let mapleader = " "        " Set leader to spacebar (recommended)
" let mapleader = ","      " Alternative: set leader to comma
" let mapleader = "\"     " Alternative: set leader to backslash (default)

" Journal integration plugin
source /home/kcaldwell/Documents/dotfiles/vim-journal.vim

