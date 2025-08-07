#!/bin/bash
# Remove a project worktree and associated branches

PWD_NAME=$(pwd)
PROJ_NAME=$1
cd ~/driving
git worktree remove ../$PROJ_NAME
git branch -D $PROJ_NAME
git branch -D kcaldwell/$PROJ_NAME
if [ $(tmux display-message -p '#S') = $PROJ_NAME ]; then
    tmux switch -t home
fi
tmux kill-session -t $PROJ_NAME
cd $PWD_NAME
