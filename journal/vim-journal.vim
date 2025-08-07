" vim-journal.vim
" Journal integration plugin for vim
" Source this file from your .vimrc with: source /path/to/vim-journal.vim

" Configuration
let g:journal_script_path = '/home/kcaldwell/Documents/dotfiles/journal.sh'
let g:journal_base_path = '/home/kcaldwell/Documents/Zoox'

" Set leader key if not already set
if !exists('g:mapleader')
    let mapleader = " "
endif

" Core journal functions
function! OpenDirectoryNotes()
    let l:current_dir = getcwd()
    let l:dir_name = fnamemodify(l:current_dir, ':t')
    let l:notes_path = g:journal_base_path . '/' . l:dir_name . '/notes.md'

    " Create directory and file if they don't exist
    let l:notes_dir = fnamemodify(l:notes_path, ':h')
    if !isdirectory(l:notes_dir)
        call mkdir(l:notes_dir, 'p')
    endif

    if !filereadable(l:notes_path)
        " Create empty notes file
        call writefile([], l:notes_path)
    endif

    " Open in vertical split
    execute 'vsplit ' . l:notes_path
    echo 'Opened notes for: ' . l:dir_name
endfunction

function! FZFJournalBrowse()
    " Use FZF to browse all notes files
    call system('find ' . g:journal_base_path . ' -name "notes.md" -type f > /tmp/vim_journal_files')
    if v:shell_error == 0
        call fzf#run(fzf#wrap({
            \ 'source': 'cat /tmp/vim_journal_files | while read file; do dir=$(basename "$(dirname "$file")"); echo "$file|$dir"; done',
            \ 'options': '--delimiter="|" --with-nth=2 --preview="cat {1}"',
            \ 'sink': function('s:EditJournalFile')
        \ }))
    else
        echo "No journal files found"
    endif
endfunction

function! s:EditJournalFile(selection)
    let l:file_path = split(a:selection, '|')[0]
    execute 'edit ' . l:file_path
endfunction

" Todo functions
function! AddTodoFromVim()
    let l:todo_text = input('Add todo: ')
    if !empty(l:todo_text)
        call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -todo ' . shellescape(l:todo_text))
        echo 'Added todo: ' . l:todo_text
    endif
endfunction

function! AddTodoWithWord()
    let l:word = expand('<cword>')
    let l:filename = expand('%:t')
    let l:line_num = line('.')

    let l:default_text = 'Fix ' . l:word . ' in ' . l:filename . ':' . l:line_num
    let l:todo_text = input('Add todo: ', l:default_text)
    if !empty(l:todo_text)
        call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -todo ' . shellescape(l:todo_text))
        echo 'Added todo: ' . l:todo_text
    endif
endfunction

function! AddTodoCommandLine()
    " Use command line input which supports <C-r> pasting
    call inputsave()
    echo 'Enter todo text (use <C-r>" for paste, <C-r><C-w> for word under cursor):'
    let l:todo_text = input('Todo: ')
    call inputrestore()

    if !empty(l:todo_text)
        call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -todo ' . shellescape(l:todo_text))
        echo 'Added todo: ' . l:todo_text
    endif
endfunction

function! AddTodoWithContext()
    let l:filename = expand('%:t')
    let l:line_num = line('.')
    let l:current_line = getline('.')

    " Default todo text with context
    let l:default_text = 'Fix in ' . l:filename . ':' . l:line_num . ' - ' . trim(l:current_line)

    let l:todo_text = input('Add todo: ', l:default_text)
    if !empty(l:todo_text)
        call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -todo ' . shellescape(l:todo_text))
        echo 'Added todo: ' . l:todo_text
    endif
endfunction

function! AddTodoFromSelection() range
    let l:filename = expand('%:t')
    let l:start_line = a:firstline
    let l:end_line = a:lastline

    " Get selected text
    let l:selected_lines = getline(a:firstline, a:lastline)
    let l:selected_text = join(l:selected_lines, ' ')

    " Default todo text with selection
    let l:default_text = 'Review ' . l:filename . ':' . l:start_line . '-' . l:end_line . ' - ' . trim(l:selected_text)[:100] . '...'

    let l:todo_text = input('Add todo: ', l:default_text)
    if !empty(l:todo_text)
        call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -todo ' . shellescape(l:todo_text))
        echo 'Added todo: ' . l:todo_text
    endif
endfunction

" Code snippet functions
function! AddCodeSnippetFromSelection() range
    let l:filename = expand('%:t')
    let l:start_line = a:firstline
    let l:end_line = a:lastline
    let l:filepath = expand('%:p')

    " Get selected text
    let l:selected_lines = getline(a:firstline, a:lastline)
    let l:code_snippet = join(l:selected_lines, "\n")

    " Create a formatted code snippet note
    let l:snippet_text = "Code from " . l:filename . ":" . l:start_line . "-" . l:end_line . "\n```\n" . l:code_snippet . "\n```\n"

    " Add to journal
    call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -code ' . shellescape(l:snippet_text))
    echo 'Added code snippet from ' . l:filename . ':' . l:start_line . '-' . l:end_line
endfunction

function! AddCodeSnippetWithDescription() range
    let l:filename = expand('%:t')
    let l:start_line = a:firstline
    let l:end_line = a:lastline

    " Get selected text
    let l:selected_lines = getline(a:firstline, a:lastline)
    let l:code_snippet = join(l:selected_lines, "\n")

    " Prompt for description
    let l:description = input('Code snippet description: ')
    if empty(l:description)
        let l:description = "Code from " . l:filename . ":" . l:start_line . "-" . l:end_line
    endif

    " Create a formatted code snippet note with description
    let l:snippet_text = l:description . "\n```\n" . l:code_snippet . "\n```"

    " Add to journal
    call system('cd ' . shellescape(getcwd()) . ' && ' . g:journal_script_path . ' -code ' . shellescape(l:snippet_text))
    echo 'Added code snippet: ' . l:description
endfunction

" Keybinding definitions
function! SetupJournalKeybindings()
    " Directory and file navigation
    nnoremap <leader>n :call OpenDirectoryNotes()<CR>
    nnoremap ,n :call OpenDirectoryNotes()<CR>
    nnoremap <leader>j :call FZFJournalBrowse()<CR>

    " Todo keybindings
    nnoremap <leader>t :call AddTodoFromVim()<CR>
    nnoremap <leader>tc :call AddTodoWithContext()<CR>
    nnoremap <leader>tw :call AddTodoWithWord()<CR>
    nnoremap <leader>tp :call AddTodoCommandLine()<CR>
    vnoremap <leader>t :call AddTodoFromSelection()<CR>

    " Code snippet keybindings
    vnoremap <leader>c :call AddCodeSnippetFromSelection()<CR>
    vnoremap <leader>cd :call AddCodeSnippetWithDescription()<CR>
endfunction

" Auto-setup keybindings when this file is sourced
call SetupJournalKeybindings()

" Optional: Provide a command to reload journal keybindings
command! JournalReload call SetupJournalKeybindings()

" Plugin loaded silently - use :echo "Journal plugin active" if you need confirmation
