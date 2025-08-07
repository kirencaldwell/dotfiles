#!/bin/bash
# Refresh zooxrc environment

eval '(ssh-agent)'
eval '(ssh-add -k ~/.ssh/id_ed25519)'
if test -f scripts/shell/zooxrc.sh; then
    echo "Refreshing zooxrc"
    source scripts/shell/zooxrc.sh
fi
