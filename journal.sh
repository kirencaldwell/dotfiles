#!/bin/sh

take_note () {
  # get current time and date
  NOW=$(date)
  # note is whatever user input
  NOTE="$*"
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
    NOTE="${NOTE} - git: ${GIT}/${BRANCH}, sha: ${SHA}"
  fi
 
  # add time info to note 
  NOTE="${NOW}: ${NOTE}"
  # log note to file
  echo "$NOTE" >> ~/.my_journal.txt
  # repeat the note so the user knows what it wrote
  echo "$NOTE"
}

# main?
# parse flags
OPT="${1}"
case ${OPT} in
  # run search
  -s | search) 
    SEARCH="${2}"
    echo "Searching for $SEARCH"
    grep "$SEARCH" ~/.my_journal.txt --color
    ;;
  # default case is to take note
  *)
    take_note "$*"
    ;;
esac
