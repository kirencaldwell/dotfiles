#!/bin/bash

# Sync dotfiles script
# Keeps config files in home directory synchronized with dotfiles repository

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to backup existing file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup_file"
        print_status $YELLOW "  ✓ Backed up existing file to: $backup_file"
    fi
}

# Function to sync a single file
sync_file() {
    local filename=$1
    local source_file="$DOTFILES_DIR/$filename"
    local target_file="$HOME/$filename"

    print_status $BLUE "Syncing $filename..."

    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        print_status $RED "  ✗ Source file not found: $source_file"
        return 1
    fi

    # Check if files are different
    if [ -f "$target_file" ] && cmp -s "$source_file" "$target_file"; then
        print_status $GREEN "  ✓ Files are already in sync"
        return 0
    fi

    # Backup existing file if it exists and is different
    if [ -f "$target_file" ]; then
        backup_file "$target_file"
    fi

    # Copy file from dotfiles to home directory
    cp "$source_file" "$target_file"

    if [ $? -eq 0 ]; then
        print_status $GREEN "  ✓ Successfully synced $filename"
    else
        print_status $RED "  ✗ Failed to sync $filename"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Sync configuration files from dotfiles directory to home directory"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -n, --dry-run  Show what would be synced without making changes"
    echo "  -f, --force    Skip confirmation prompts"
    echo "  -v, --verbose  Show detailed output"
    echo ""
    echo "Files synchronized:"
    echo "  • .vimrc"
    echo "  • .tmux.conf"
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
print_status $BLUE "=== Dotfiles Sync Script ==="
print_status $BLUE "Dotfiles directory: $DOTFILES_DIR"
print_status $BLUE "Target directory: $HOME"
echo ""

# Files to sync
FILES_TO_SYNC=(".vimrc" ".tmux.conf")

if [ "$DRY_RUN" = true ]; then
    print_status $YELLOW "DRY RUN MODE - No files will be modified"
    echo ""

    for file in "${FILES_TO_SYNC[@]}"; do
        source_file="$DOTFILES_DIR/$file"
        target_file="$HOME/$file"

        print_status $BLUE "Would sync: $file"

        if [ ! -f "$source_file" ]; then
            print_status $RED "  ✗ Source file not found: $source_file"
            continue
        fi

        if [ -f "$target_file" ] && cmp -s "$source_file" "$target_file"; then
            print_status $GREEN "  ✓ Files are already in sync"
        else
            print_status $YELLOW "  → Would copy: $source_file → $target_file"
            if [ -f "$target_file" ]; then
                print_status $YELLOW "  → Would backup: $target_file"
            fi
        fi
    done
    exit 0
fi

# Ask for confirmation unless force flag is used
if [ "$FORCE" != true ]; then
    echo "This will sync the following files from dotfiles to your home directory:"
    for file in "${FILES_TO_SYNC[@]}"; do
        echo "  • $file"
    done
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status $YELLOW "Sync cancelled by user"
        exit 0
    fi
    echo ""
fi

# Perform the sync
SUCCESS_COUNT=0
TOTAL_COUNT=${#FILES_TO_SYNC[@]}

for file in "${FILES_TO_SYNC[@]}"; do
    if sync_file "$file"; then
        ((SUCCESS_COUNT++))
    fi
    echo ""
done

# Summary
print_status $BLUE "=== Sync Complete ==="
print_status $GREEN "Successfully synced: $SUCCESS_COUNT/$TOTAL_COUNT files"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    print_status $GREEN "All files synced successfully! 🎉"
    exit 0
else
    print_status $YELLOW "Some files failed to sync. Check the output above for details."
    exit 1
fi
