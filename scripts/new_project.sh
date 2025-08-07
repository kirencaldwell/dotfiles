#!/bin/bash
# Create a new project worktree and tmux session

PWD_NAME=$(pwd)
PROJ_NAME=$1
cd ~/driving
git worktree add ../$PROJ_NAME
cd ../$PROJ_NAME
if [ -n "$2" ]; then
    BASE=$2
    git checkout --track $BASE -b kcaldwell/$PROJ_NAME
else
    git checkout --track origin/master -b kcaldwell/$PROJ_NAME
fi
TMUX= tmux new-session -d -s $PROJ_NAME
tmux switch-client -t $PROJ_NAME
cd $PWD_NAME
