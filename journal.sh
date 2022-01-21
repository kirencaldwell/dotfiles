#!/bin/sh

#now=$(date +"%T")
now=$(date)
note_to_print=$*
echo "$now: $note_to_print" >> ~/.my_journal.txt
echo "$now: $note_to_print"
