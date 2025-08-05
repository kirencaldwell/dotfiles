#!/bin/bash

# This script is designed to be run inside a tmux session to extract the LAST
# URL from the current pane's history. It looks for a link that is
# preceded by the string "ARGUS:".
#
# This version uses a robust combination of grep, awk, and tail to reliably
# extract only the URL. This approach is less sensitive to subtle differences
# in how regular expressions are handled in different environments.
#
# Usage example:
# # Assuming a link was printed 100 lines ago, and another one 2 lines ago
# ./find_link.sh
# This will return only the link from 2 lines ago.

# The command is structured in a pipeline:
# 1. 'tmux capture-pane -p' gets the full pane history as multiple lines.
#    (Note: The '-e' flag has been removed as it can cause issues by
#    treating the entire output as a single line.)
# 2. 'grep 'ARGUS:'' filters for lines containing the keyword.
# 3. 'awk '{print $NF}'' prints the last field of the matching line,
#    which in this case is the URL.
# 4. 'tail -1' selects only the last match from the history.

tmux capture-pane -pS - | grep 'ARGUS: https' | awk '{print $NF}'
