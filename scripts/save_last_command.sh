#!/bin/bash
# Save the last command to saved_commands.txt with git branch info

BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);
COMMAND=$(fc -ln -1);
echo "\`$BRANCH\` $COMMAND"
echo -e "\x60\x23 $BRANCH\x60 $COMMAND" >> ~/saved_commands.txt
