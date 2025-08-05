#!/bin/bash
DAILY_PATH="/home/kcaldwell/Documents/Zoox"
# get current time and date
NOW=$(date)
TODAY=$(date +%F)
DIR_NAME=$(basename "`pwd`")

LINK="${1}"
NOTE="${2}"


take_note () {
  # get git repo name
  GIT=$(basename -s .git `git config --get remote.origin.url` 2> /dev/null)
  # get current git branch (suppress output)
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);
  # get current git sha (suppress output)
  SHA=$(git rev-parse --short HEAD 2> /dev/null);
  # read status to determine if we're even in a git repo
  STATUS=$?

  # if we're in a git repo, then add that info
  if [ $STATUS -eq 0 ]
  then
    STASH=$(git stash create)
    RES="|${NOW}|${LINK}|${NOTE}|git: ${GIT}/${BRANCH}, sha: ${SHA}, stash: ${STASH}|"
  fi
 
  # add time info to note 
  # log note to file
  mkdir -p ${DAILY_PATH}/${DIR_NAME}
  echo "$RES" >> ${DAILY_PATH}/${DIR_NAME}/results.md
  # repeat the note so the user knows what it wrote
  echo "${NOTE_COLOR}$RES${NC}"
}

take_note
