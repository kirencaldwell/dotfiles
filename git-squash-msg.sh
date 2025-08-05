#!/bin/bash

# This script is designed to be run during a `git rebase --interactive`
# session, specifically after you have made changes and created a new
# commit with a tool (like 'gcm').
#
# It will automatically grab the commit message from the new commit,
# combine it with the message of the commit you are currently editing,
# and then squash the changes into that previous commit.

# Check if there is a recent commit to grab a message from.
# This ensures the script doesn't fail if run at the wrong time.
if ! git rev-parse HEAD~1 &>/dev/null; then
    echo "Error: Could not find a recent commit to amend. Make sure you've already committed your changes."
    exit 1
fi

# 1. Grab the commit message from the original commit we're editing (HEAD~1).
OLD_COMMIT_MSG=$(git log -1 --pretty=%B HEAD~1)

# 2. Grab the commit message from the new commit created by 'gcm' (HEAD).
NEW_COMMIT_MSG=$(git log -1 --pretty=%B HEAD)

# 3. Combine the old and new messages into a temporary file.
# We use a blank line and a separator to keep the messages distinct.
TEMP_MSG_FILE=$(mktemp)
echo -e "${OLD_COMMIT_MSG}\n\n---\n\n${NEW_COMMIT_MSG}" > "$TEMP_MSG_FILE"

# 4. Undo the most recent commit, but keep the changes staged.
# The --soft flag keeps the files in the index, ready to be committed again.
git reset --soft HEAD~1

# 5. Amend the previous commit with the combined message from the temporary file.
# The `-F` flag tells Git to use the content of the file for the commit message,
# completely bypassing the interactive editor.
git commit --amend -F "$TEMP_MSG_FILE"

# 6. Clean up the temporary file after you're done.
rm "$TEMP_MSG_FILE"

echo "Amend operation complete. Don't forget to run 'git rebase --continue' to finish the rebase."

