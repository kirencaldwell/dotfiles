#!/bin/sh

take_note () {
  NOW=$(date)
  NOTE="$*"
  echo "$NOW: $NOTE" >> ~/.my_journal.txt
  echo "$NOW: $NOTE"
}

OPT="${1}"
case ${OPT} in
  -s | search) SEARCH="${2}"
    echo "Searching for $SEARCH"
    grep $SEARCH ~/.my_journal.txt --color
    ;;
  *)
    take_note "$*"
    ;;
esac
