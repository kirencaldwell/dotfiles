#!/bin/bash

# Journal script for taking notes and managing todos
# Maintains notes in markdown format organized by current directory

set -eu

# Configuration
readonly DAILY_PATH="/home/kcaldwell/Documents/Zoox"
readonly NOTE_COLOR='\033[0;93m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color
readonly EDITOR="vim"

# Global variables
NOW=$(date)
TODAY=$(date +%F)
readonly DIR_NAME=$(basename "$(pwd)")
readonly NOTES_FILE="${DAILY_PATH}/${DIR_NAME}/notes.md"

# Utility functions
log_info() {
    echo "${NOTE_COLOR}$*${NC}"
}

log_error() {
    echo "${RED}$*${NC}" >&2
}

ensure_notes_dir() {
    mkdir -p "${DAILY_PATH}/${DIR_NAME}"
}

get_git_info() {
    local git_repo branch sha stash_id

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        return 1
    fi

    git_repo=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" 2>/dev/null || echo "unknown")
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    stash_id=$(git stash create 2>/dev/null || echo "")

    echo "git: ${git_repo}/${branch}, sha: ${sha}, stash: ${stash_id}"
}

# Core note-taking functions
open_note() {
    if [ -n "$EDITOR" ]; then
        $EDITOR $NOTES_FILE
    elif command -v vim >/dev/null 2>&1; then
        vim $NOTES_FILE
    elif command -v nano >/dev/null 2>&1; then
        nano $NOTES_FILE
    else
        view_note
    fi
}

view_note() {
    if [ -f "$NOTES_FILE" ]; then
        cat "$NOTES_FILE"
    else
        log_info "No notes file found for directory: $DIR_NAME"
    fi
}

take_note() {
    local note="$*"
    local git_info

    ensure_notes_dir

    # Add git information if we're in a git repository
    if git_info=$(get_git_info); then
        note="${note} - ${git_info}"
    fi

    # Add note to file
    echo "\n$note" >> "$NOTES_FILE"

    # Echo back to user
    log_info "$note"
}

# Todo management functions
generate_todo_id() {
    echo "@$(openssl rand -hex 3)"
}

add_todo() {
    local todo_id
    todo_id=$(generate_todo_id)
    take_note "- [ ] #todo ${todo_id} ${NOW}: $*"
}

list_todos() {
    log_info "Listing todos"
    if ! grep -r --exclude-dir=".*" -h -F "[ ] #todo" "${DAILY_PATH}/${DIR_NAME}/" 2>/dev/null | sort; then
        log_info "No open todos found"
    fi
}

delete_todo() {
    local todo_id="$1"
    log_info "Marking todo ${RED}@${todo_id} ${NOTE_COLOR}as done"

    if ! grep -rlF "[ ] #todo @${todo_id}" "$DAILY_PATH" 2>/dev/null | xargs -r sed -i -e "s/\\[ \\] #todo @${todo_id}/\\[x\\] #todo @${todo_id}/g"; then
        log_error "Todo @${todo_id} not found"
        return 1
    fi
}

fzf_complete_todo() {
    # Get open todos with their full text for FZF selection
    local todos_file="/tmp/journal_todos_$$"

    # Create a temporary file with todos in format: "hash: description"
    # Extract just the hash and the description part before any dash
    grep -r --exclude-dir=".*" "\\[ \\] #todo @[a-f0-9]\\{6\\}" "${DAILY_PATH}/${DIR_NAME}/" 2>/dev/null | \
    sed 's/.*@\([a-f0-9]\{6\}\).*: \([^-]*[^[:space:]]\)[[:space:]]*-.*/\1: \2/' > "$todos_file"

    if [ ! -s "$todos_file" ]; then
        log_info "No open todos found"
        rm -f "$todos_file"
        return 1
    fi

    # Use FZF to select a todo
    local selected
    selected=$(cat "$todos_file" | fzf --prompt="Select todo to complete: " --height=40% --reverse --border)

    rm -f "$todos_file"

    if [ -n "$selected" ]; then
        # Extract the hash from the selected line
        local todo_id=$(echo "$selected" | cut -d: -f1)
        delete_todo "$todo_id"
    else
        log_info "No todo selected"
    fi
}

list_done() {
    log_info "Listing finished items"
    if ! grep -rF --exclude-dir=".*" -h "[x] #todo" "${DAILY_PATH}/${DIR_NAME}/" 2>/dev/null | sort; then
        log_info "No completed todos found"
    fi
}

reopen_todo() {
    local todo_id="$1"
    log_info "Reopening todo ${RED}@${todo_id}"

    if ! grep -rlF "[x] #todo @${todo_id}" "$DAILY_PATH" 2>/dev/null | xargs -r sed -i -e "s/\\[x\\] #todo @${todo_id}/\\[ \\] #todo @${todo_id}/g"; then
        log_error "Completed todo @${todo_id} not found"
        return 1
    fi
}

fzf_reopen_todo() {
    # Get completed todos with their full text for FZF selection
    local todos_file="/tmp/journal_done_todos_$$"

    # Create a temporary file with completed todos in format: "hash: description"
    # Extract just the hash and the description part before any dash
    grep -r --exclude-dir=".*" "\\[x\\] #todo @[a-f0-9]\\{6\\}" "$DAILY_PATH" 2>/dev/null | \
    sed 's/.*@\([a-f0-9]\{6\}\).*: \([^-]*[^[:space:]]\)[[:space:]]*-.*/\1: \2/' > "$todos_file"

    if [ ! -s "$todos_file" ]; then
        log_info "No completed todos found"
        rm -f "$todos_file"
        return 1
    fi

    # Use FZF to select a todo to reopen
    local selected
    selected=$(cat "$todos_file" | fzf --prompt="Select todo to reopen: " --height=40% --reverse --border)

    rm -f "$todos_file"

    if [ -n "$selected" ]; then
        # Extract the hash from the selected line
        local todo_id=$(echo "$selected" | cut -d: -f1)
        reopen_todo "$todo_id"
    else
        log_info "No todo selected"
    fi
}

# Question management functions
add_question() {
    local question_id
    question_id=$(generate_todo_id)
    take_note "$question_id #question ${NOW}: $*"
}

list_questions() {
    log_info "Listing questions"
    if ! grep -r --exclude-dir=".*" "#question" "$DAILY_PATH" --color 2>/dev/null; then
        log_info "No questions found"
    fi
}

# Code snippet functions
add_code() {
    take_note "#code $*"
}

list_code() {
    log_info "Listing code snippets"
    # Note: Original script references ~/.my_journal.txt which seems inconsistent
    # Keeping the original behavior but this might need adjustment
    if [ -f ~/.my_journal.txt ]; then
        grep "#code" ~/.my_journal.txt --color || log_info "No code snippets found"
    else
        log_info "Code journal file not found"
    fi
}

# Search function
search_notes() {
    local search_term="$1"
    log_info "Searching for ${RED}$search_term"

    # Note: Original script searches ~/.my_journal.txt, keeping this behavior
    if [ -f ~/.my_journal.txt ]; then
        grep "$search_term" ~/.my_journal.txt --color || log_info "No matches found"
    else
        log_info "Journal file not found"
    fi
}

# Enhanced FZF search with preview across all notes
fzf_search_notes() {
    local search_results="/tmp/journal_search_$$"

    # Find all notes files and their content with line numbers
    find "$DAILY_PATH" -name "notes.md" -type f -exec grep -Hn "." {} \; 2>/dev/null > "$search_results"

    if [ ! -s "$search_results" ]; then
        log_info "No notes found"
        rm -f "$search_results"
        return 1
    fi

        # Use FZF with preview showing the context around the selected line
    local selected
    selected=$(cat "$search_results" | fzf \
        --prompt="Search notes: " \
        --height=80% \
        --reverse \
        --border \
        --preview 'file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); if [ -f "$file" ] && [ "$line" -gt 0 ] 2>/dev/null; then start=$((line > 5 ? line - 5 : 1)); sed -n "${start},$((line + 5))p" "$file" | nl -ba -v $start; else echo "Preview not available"; fi' \
        --preview-window=right:50%)

    if [ -n "$selected" ]; then
        local selected_file=$(echo "$selected" | cut -d: -f1)
        local selected_line=$(echo "$selected" | cut -d: -f2)
        log_info "Opening: $selected_file at line $selected_line"
        if [ -n "$EDITOR" ]; then
            $EDITOR "+$selected_line" "$selected_file"
        elif command -v vim >/dev/null 2>&1; then
            vim "+$selected_line" "$selected_file"
        elif command -v nano >/dev/null 2>&1; then
            nano "+$selected_line" "$selected_file"
        else
            less "+$selected_line" "$selected_file"
        fi
    else
        log_info "No search result selected"
    fi

    rm -f "$search_results"
}

# Browse all notes with FZF and preview
fzf_browse_notes() {
    local notes_list="/tmp/journal_browse_$$"

    # Create list of all notes with their directory context
    find "$DAILY_PATH" -name "notes.md" -type f | while read -r file; do
        local dir_name=$(basename "$(dirname "$file")")
        local line_count=$(wc -l < "$file" 2>/dev/null || echo "0")
        echo "$file|$dir_name ($line_count lines)"
    done > "$notes_list"

    if [ ! -s "$notes_list" ]; then
        log_info "No notes found"
        rm -f "$notes_list"
        return 1
    fi

        # Use FZF to browse notes with preview
    local selected
    selected=$(cat "$notes_list" | fzf \
        --prompt="Browse notes: " \
        --height=80% \
        --reverse \
        --border \
        --delimiter="|" \
        --with-nth=2 \
        --preview 'file=$(echo {} | cut -d"|" -f1); if [ -f "$file" ]; then cat "$file"; else echo "File not found"; fi' \
        --preview-window=right:60%)

    if [ -n "$selected" ]; then
        local selected_file=$(echo "$selected" | cut -d"|" -f1)
        log_info "Opening: $selected_file"
        if [ -n "$EDITOR" ]; then
            $EDITOR "$selected_file"
        elif command -v vim >/dev/null 2>&1; then
            vim "$selected_file"
        elif command -v nano >/dev/null 2>&1; then
            nano "$selected_file"
        else
            less "$selected_file"
        fi
    else
        log_info "No file selected"
    fi

    rm -f "$notes_list"
}

# Directory switching with FZF
fzf_switch_directory() {
    local dirs_list="/tmp/journal_dirs_$$"

    # Find all directories that contain notes
    find "$DAILY_PATH" -name "notes.md" -type f -exec dirname {} \; | while read -r dir; do
        local dir_name=$(basename "$dir")
        local note_file="$dir/notes.md"
        local todo_count=$(grep -c "\\[ \\] #todo" "$note_file" 2>/dev/null || echo "0")
        local done_count=$(grep -c "\\[x\\] #todo" "$note_file" 2>/dev/null || echo "0")
        local last_modified=$(stat -c %y "$note_file" 2>/dev/null | cut -d' ' -f1)
        echo "$dir|$dir_name - $todo_count open, $done_count done (last: $last_modified)"
    done | sort -t'|' -k2 > "$dirs_list"

    if [ ! -s "$dirs_list" ]; then
        log_info "No directories with notes found"
        rm -f "$dirs_list"
        return 1
    fi

    # Use FZF to select directory
    local selected
    selected=$(cat "$dirs_list" | fzf \
        --prompt="Switch to directory: " \
        --height=40% \
        --reverse \
        --border \
        --delimiter="|" \
        --with-nth=2 \
        --preview 'dir=$(echo {} | cut -d"|" -f1); if [ -f "$dir/notes.md" ]; then cat "$dir/notes.md"; else echo "No notes found"; fi' \
        --preview-window=right:60%)

    if [ -n "$selected" ]; then
        local target_dir=$(echo "$selected" | cut -d"|" -f1)
        local target_name=$(basename "$target_dir")
        log_info "Switching to directory: $target_name"
        echo "cd \"$(dirname "$target_dir")/$target_name\""
        # Note: User will need to eval this output or we could create a function
    else
        log_info "No directory selected"
    fi

    rm -f "$dirs_list"
}

# Placeholder functions for missing functionality
answer_question() {
    log_error "Answer question functionality not implemented"
    return 1
}

list_answers() {
    log_error "List answers functionality not implemented"
    return 1
}

# Help function
show_help() {
    cat << EOF
Journal Script - Note taking and todo management

Usage: $0 [OPTION] [ARGUMENTS...]

Options:
  -s, -search [TERM]   Search for TERM (interactive FZF if no term provided)
  -sf                  Interactive FZF search with live preview
  -browse, -b          Browse all notes with FZF and preview
  -cd, -switch         Switch to a different directory using FZF
  -tq, -q, -question   Add a question
  -ql                  List questions
  -qa                  Answer a question (not implemented)
  -al                  List answers (not implemented)
  -ta, -t, -todo       Add a todo item
  -tl                  List open todos
  -tm [ID]             Mark todo as done (interactive FZF if no ID provided)
  -tmf                 Mark todo as done using FZF (always interactive)
  -td                  List completed todos
  -tr [ID]             Reopen todo (interactive FZF if no ID provided)
  -trf                 Reopen todo using FZF (always interactive)
  -c, -code            Add code snippet
  -cl, -code_list      List code snippets
  -v, -view            View notes for current directory
  -h, --help           Show this help message

  Default: Take a note with timestamp

Examples:
  $0 "This is a note"
  $0 -todo "Fix the bug in authentication"
  $0 -tm abc123
  $0 -search "authentication"
  $0 -search               # Interactive FZF search
  $0 -browse               # Browse all notes with preview
  $0 -cd                   # Switch directory interactively
EOF
}

# Main execution
main() {
    if [ $# -eq 0 ]; then
        show_help
        return 0
    fi

    local opt="$1"
    shift

    case "$opt" in
        -s|-search)
            if [ $# -eq 0 ]; then
                # No search term provided, use FZF for interactive search
                fzf_search_notes
            else
                # Search term provided, use traditional search
                search_notes "$1"
            fi
            ;;
        -sf)
            # Force FZF search mode
            fzf_search_notes
            ;;
        -browse|-b)
            # Browse all notes with FZF
            fzf_browse_notes
            ;;
        -cd|-switch)
            # Switch directories with FZF
            fzf_switch_directory
            ;;
        -tq|-q|-question)
            [ $# -eq 0 ] && { log_error "Question text required"; return 1; }
            add_question "$*"
            ;;
        -ql)
            list_questions
            ;;
        -qa)
            answer_question "$*"
            ;;
        -al)
            list_answers
            ;;
        -ta|-t|-todo)
            [ $# -eq 0 ] && { log_error "Todo text required"; return 1; }
            add_todo "$*"
            ;;
        -tl)
            list_todos
            ;;
        -tm)
            if [ $# -eq 0 ]; then
                # No ID provided, use FZF for interactive selection
                fzf_complete_todo
            else
                # ID provided, use traditional method
                delete_todo "$1"
            fi
            ;;
        -tmf)
            # Force FZF mode even if arguments are provided
            fzf_complete_todo
            ;;
        -td)
            list_done
            ;;
        -tr)
            if [ $# -eq 0 ]; then
                # No ID provided, use FZF for interactive selection
                fzf_reopen_todo
            else
                # ID provided, use traditional method
                reopen_todo "$1"
            fi
            ;;
        -trf)
            # Force FZF mode even if arguments are provided
            fzf_reopen_todo
            ;;
        -c|-code)
            [ $# -eq 0 ] && { log_error "Code snippet required"; return 1; }
            add_code "$*"
            ;;
        -cl|-code_list)
            list_code
            ;;
        -v|-view)
            view_note
            ;;
        -o|-open)
            open_note
            ;;
        -h|--help)
            show_help
            ;;
        *)
            # Default case: take note with timestamp
            take_note "${NOW}: $opt $*"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
