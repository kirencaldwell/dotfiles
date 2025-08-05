#!/bin/bash
DAILY_PATH="/home/kcaldwell/Documents/Zoox"
# get current time and date
NOW=$(date)
TODAY=$(date +%F)
DIR_NAME=$(basename "`pwd`")

view_note() {
  cat ${DAILY_PATH}/${DIR_NAME}/notes.md 
}

take_note () {
  # get current date
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
    STASH=$(git stash create)
    NOTE="${NOTE} - git: ${GIT}/${BRANCH}, sha: ${SHA}, stash: ${STASH}"
  fi
 
  # add time info to note 
  # log note to file
  mkdir -p ${DAILY_PATH}/${DIR_NAME}
  echo "\n$NOTE" >> ${DAILY_PATH}/${DIR_NAME}/notes.md
  # repeat the note so the user knows what it wrote
  echo "${NOTE_COLOR}$NOTE${NC}"
}

add_todo() {
  N="@$(openssl rand -hex 3)"
  take_note "- [ ] #todo ${N} ${NOW}: $*" 
}
list_todos() {
  echo "${NOTE_COLOR}Listing todos${NC}"
  grep -r --exclude-dir=".*" -F "[ ] #todo" ${DAILY_PATH}/${DIR_NAME}/ --color | sort -t: -k2,2nr

}
delete_todo() {
  echo "${NOTE_COLOR}Marking todo ${RED}@${1} ${NOTE_COLOR}as done${NC}"
  grep -rlF "[ ] #todo @${1}" ${DAILY_PATH} | xargs sed -i -e "s/\[ \] #todo @${1}/\[x\] #todo @${1}/g"
}
list_done() {
  echo "${NOTE_COLOR}Listing finished items${NC}"
  grep -rF --exclude-dir=".*" "[x] #todo" ${DAILY_PATH} --color | sort -t: -k2,2nr
}
reopen_todo() {
  echo "${NOTE_COLOR}Reopening todo ${RED}#${1}${NC}"
  grep -rlF "[x] #todo @${1}" ${DAILY_PATH} | xargs sed -i -e "s/\[x\] #todo @${1}/\[ \] #todo @${1}/g"
} 

add_question() {
  N="@$(openssl rand -hex 3)"
  take_note "$N #question ${NOW}: $*" 
}
list_questions() {
  echo "${NOTE_COLOR}Listing questions${NC}"
  grep -r --exclude-dir=".*" "#question" ${DAILY_PATH} --color
}
list_code() {
  echo "${NOTE_COLOR}Listing code snippets${NC}"
  grep "#code" ~/.my_journal.txt --color
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
  -s | -search) 
    SEARCH="${1}"
    echo "${NOTE_COLOR}Searching for ${RED}$SEARCH${NC}"
    grep "$SEARCH" ~/.my_journal.txt --color
    ;;
  # show N recent entries
  -tq | -q | -question)
    add_question "$*"
    ;;
  -ql) 
    list_questions "$*"
    ;;
  -qa)
    answer_question "$*"
    ;;
  -al)
    list_answers
    ;;
  -ta | -t | -todo)
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
  -tr)
    reopen_todo "$*" 
    ;;
  -c | -code)
    take_note "#code $*"
    ;;
  -cl | -code_list)
    list_code
    ;;
  -v | -view)
    view_note
    ;;
  # default case is to take note
  *)
    take_note "${NOW}: $OPT $*"
    ;;
esac
