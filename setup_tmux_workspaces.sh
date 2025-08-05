#!/bin/bash

# This script finds all Git worktrees in a specified directory,
# creates a new tmux session for each one, and sets up a
# horizontal split in the first window of each session.

# --- Configuration ---
# The base directory to search for Git worktrees.
BASE_DIR="$HOME/driving"

# --- Main Script ---

echo "Searching for Git worktrees in: $BASE_DIR"

# Use 'git worktree list --porcelain' for a more machine-readable output.
# The 'while read' loop is a robust way to process the output line by line.
# We parse the path of each worktree from the output.
git -C "$BASE_DIR" worktree list --porcelain | while read -r line; do
    # 'worktree list --porcelain' gives the path on the first line of each block.
    # We check if the line starts with 'worktree '.
    if [[ "$line" == "worktree "* ]]; then
        # Extract the path by removing the 'worktree ' prefix and stripping whitespace.
        WORKTREE_PATH=$(echo "$line" | sed 's/^worktree //')

        # Get the name of the worktree from its path.
        # This will be used as the session name.
        SESSION_NAME=$(basename "$WORKTREE_PATH")

        # Check if a session with this name already exists.
        # This prevents errors if you run the script multiple times.
        if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            echo "-> Creating tmux session '$SESSION_NAME' for worktree: $WORKTREE_PATH"

            # 1. Create a new detached session with the name of the worktree.
            #    The -c flag sets the working directory for the session.
            tmux new-session -d -s "$SESSION_NAME" -c "$WORKTREE_PATH"

            # 2. Create a new pane with a horizontal split in the first window (window 0).
            #    This is targeted at the session we just created.
            tmux split-window -v -t "$SESSION_NAME:0" -c "$WORKTREE_PATH"
        else
            echo "-> Skipping '$SESSION_NAME', session already exists."
        fi

        if ! tmux has-session -t "home" 2>/dev/null; then
          tmux new-session -d -s "home" -c "~"
          tmux split-window -v -t "home" -c "~"
        fi
    fi
done

tmux attach -t home


