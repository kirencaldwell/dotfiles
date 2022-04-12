#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
#while true;
#do
  TMUX_INFO=$(tmux list-panes -a -F "#{pane_pid} #{session_name}")
  SESSION_NAMES=$(tmux list-sessions -F "#{session_name}")
  N=0
  OUT="Sessions: "
  for i in $SESSION_NAMES; 
  do 
    CPU='0.0'
    PANE_PIDS=$(tmux list-panes -s -F "#{pane_pid}" -t $i)
    for k in $PANE_PIDS;
    do
      CHILD_PIDS=$(echo $(ps -o pid -g $k | tail -n +2))
      for j in $CHILD_PIDS;
      do
        CHILD_CPU=$(ps -p $j -o %cpu 2> /dev/null | tail -n 1 )
        CPU=$(echo "$CPU + $CHILD_CPU" | bc 2> /dev/null)
      done
    done;
    if [ "$1" = "-s" ]; then
      OUT="${OUT}($N)$i[$CPU] "
    else
      if (( $(echo "$CPU > 100" |bc -l) ));
      then
        OUT="${OUT} ($N)${RED}$i${NC} [$CPU], "
      elif (( $(echo "$CPU > 0" |bc -l) ));
      then
        OUT="${OUT} ($N)${ORANGE}$i${NC} [$CPU], "
      else
        OUT="${OUT} ($N)${GREEN}$i${NC} [$CPU], "
      fi
    fi
    N=$((N+1))
  done;
  if [ "$1" = "-s" ]; then
    echo "$OUT"
  else
    echo -e "$OUT \e[1A"
  fi
  sleep 1
  
#done;
