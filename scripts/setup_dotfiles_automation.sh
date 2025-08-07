#!/bin/bash

# Setup automation for dotfiles sync
# Provides options for automatic syncing of dotfiles

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
SYNC_SCRIPT="$SCRIPT_DIR/sync_dotfiles.sh"

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Setup automation for dotfiles synchronization"
    echo ""
    echo "Commands:"
    echo "  install-cron     Install a cron job to sync dotfiles hourly"
    echo "  remove-cron      Remove the dotfiles sync cron job"
    echo "  install-git-hook Install a git post-commit hook to auto-sync"
    echo "  remove-git-hook  Remove the git post-commit hook"
    echo "  status          Show current automation status"
    echo "  help            Show this help message"
    echo ""
    echo "Manual sync options:"
    echo "  You can always run: sync_dotfiles [options]"
    echo "  Or directly: $SYNC_SCRIPT [options]"
}

# Function to install cron job
install_cron() {
    local cron_command="$SYNC_SCRIPT --force"
    local cron_job="0 * * * * $cron_command # dotfiles-sync"

    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "dotfiles-sync"; then
        print_status $YELLOW "Dotfiles sync cron job already exists"
        return 0
    fi

    # Add the cron job
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -

    if [ $? -eq 0 ]; then
        print_status $GREEN "✓ Cron job installed successfully"
        print_status $BLUE "  Dotfiles will be synced every hour"
        print_status $BLUE "  Command: $cron_command"
    else
        print_status $RED "✗ Failed to install cron job"
        return 1
    fi
}

# Function to remove cron job
remove_cron() {
    if ! crontab -l 2>/dev/null | grep -q "dotfiles-sync"; then
        print_status $YELLOW "No dotfiles sync cron job found"
        return 0
    fi

    # Remove the cron job
    crontab -l 2>/dev/null | grep -v "dotfiles-sync" | crontab -

    if [ $? -eq 0 ]; then
        print_status $GREEN "✓ Cron job removed successfully"
    else
        print_status $RED "✗ Failed to remove cron job"
        return 1
    fi
}

# Function to install git hook
install_git_hook() {
    local git_dir="$DOTFILES_DIR/.git"
    local hook_file="$git_dir/hooks/post-commit"

    if [ ! -d "$git_dir" ]; then
        print_status $RED "✗ Not a git repository: $DOTFILES_DIR"
        return 1
    fi

    # Create hooks directory if it doesn't exist
    mkdir -p "$git_dir/hooks"

    # Check if hook already exists
    if [ -f "$hook_file" ] && grep -q "sync_dotfiles" "$hook_file"; then
        print_status $YELLOW "Git post-commit hook already contains dotfiles sync"
        return 0
    fi

    # Create or append to post-commit hook
    cat >> "$hook_file" << EOF

# Auto-sync dotfiles after commit
echo "Auto-syncing dotfiles..."
$SYNC_SCRIPT --force
EOF

    # Make hook executable
    chmod +x "$hook_file"

    if [ $? -eq 0 ]; then
        print_status $GREEN "✓ Git post-commit hook installed successfully"
        print_status $BLUE "  Dotfiles will be synced after each commit"
    else
        print_status $RED "✗ Failed to install git hook"
        return 1
    fi
}

# Function to remove git hook
remove_git_hook() {
    local git_dir="$DOTFILES_DIR/.git"
    local hook_file="$git_dir/hooks/post-commit"

    if [ ! -f "$hook_file" ]; then
        print_status $YELLOW "No post-commit hook found"
        return 0
    fi

    if ! grep -q "sync_dotfiles" "$hook_file"; then
        print_status $YELLOW "Post-commit hook doesn't contain dotfiles sync"
        return 0
    fi

    # Create a backup
    cp "$hook_file" "$hook_file.backup.$(date +%Y%m%d_%H%M%S)"

    # Remove dotfiles sync section
    sed -i '/# Auto-sync dotfiles after commit/,/sync_dotfiles.*--force/d' "$hook_file"

    # If hook is now empty (except for shebang), remove it
    if [ $(wc -l < "$hook_file") -le 2 ]; then
        rm "$hook_file"
    fi

    print_status $GREEN "✓ Git post-commit hook cleaned successfully"
}

# Function to show status
show_status() {
    print_status $BLUE "=== Dotfiles Automation Status ==="
    print_status $BLUE "Dotfiles directory: $DOTFILES_DIR"
    print_status $BLUE "Sync script: $SYNC_SCRIPT"
    echo ""

    # Check cron job
    if crontab -l 2>/dev/null | grep -q "dotfiles-sync"; then
        print_status $GREEN "✓ Cron job: ACTIVE"
        print_status $BLUE "  $(crontab -l 2>/dev/null | grep dotfiles-sync | head -1)"
    else
        print_status $YELLOW "✗ Cron job: NOT ACTIVE"
    fi

    # Check git hook
    local git_dir="$DOTFILES_DIR/.git"
    local hook_file="$git_dir/hooks/post-commit"

    if [ -f "$hook_file" ] && grep -q "sync_dotfiles" "$hook_file"; then
        print_status $GREEN "✓ Git post-commit hook: ACTIVE"
    else
        print_status $YELLOW "✗ Git post-commit hook: NOT ACTIVE"
    fi

    echo ""
    print_status $BLUE "Manual sync command: sync_dotfiles [options]"
}

# Main execution
case "${1:-help}" in
    install-cron)
        print_status $BLUE "Installing cron job for dotfiles sync..."
        install_cron
        ;;
    remove-cron)
        print_status $BLUE "Removing cron job for dotfiles sync..."
        remove_cron
        ;;
    install-git-hook)
        print_status $BLUE "Installing git post-commit hook for dotfiles sync..."
        install_git_hook
        ;;
    remove-git-hook)
        print_status $BLUE "Removing git post-commit hook for dotfiles sync..."
        remove_git_hook
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_status $RED "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
