#!/bin/bash

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
  echo "${NOTE_COLOR}$NOTE${NC}"
}

add_todo() {
  # N=$(grep -c "@todo" ~/.my_journal.txt);
  # N=$((N+1))  
  N="#$(openssl rand -hex 3)"
  take_note "${RED}$N@todo${NC} $*" 
}

list_todos() {
  echo "${NOTE_COLOR}Listing todos${NC}"
  grep "@todo" ~/.my_journal.txt --color
}
delete_todo() {
  echo "${NOTE_COLOR}Marking todo ${RED}#${1} ${NOTE_COLOR}as done${NC}"
  find ~/.my_journal.txt -type f -exec sed -i "s/${1}@todo/${1}@done/g" {} \;
}
list_done() {
  echo "${NOTE_COLOR}Listing finished items${NC}"
  grep "@done" ~/.my_journal.txt --color
}

summarize() {
  tail -${1} ~/.my_journal.txt
}
  

NOTE_COLOR='\033[0;093m'
RED='\033[0;31m'
NC='\033[0m' # No Color
# main?
# parse flags
OPT="${1}"
shift
case ${OPT} in
  # run search
  -s | search) 
    SEARCH="${1}"
    echo "${NOTE_COLOR}Searching for ${RED}$SEARCH${NC}"
    grep "$SEARCH" ~/.my_journal.txt --color
    ;;
  # show N recent entries
  -p | print)
    echo "${NOTE_COLOR}Showing last ${RED}${1}${NOTE_COLOR} entries${NC}"
    summarize "${1}"
    ;;
  -ta | -t | todo)
    add_todo "$*"
    ;;
  -tl) 
    list_todos "$*"
    ;;
  -tm)
    delete_todo "$*"
    ;;
  -td)
    list_done
    ;;
  # default case is to take note
  *)
    take_note "$OPT $*"
    ;;
esac
