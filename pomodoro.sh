#!/usr/bin/env bash

# File to store the Pomodoro end time. This file's existence determines if the timer is running.
POMODORO_END_TIME_FILE="$HOME/.tmux_pomodoro_end_time"
# Default Pomodoro duration in seconds (25 minutes)
POMODORO_DURATION=50*60
NOTE_DURATION=5*60

# Function to start the Pomodoro timer.
start_pomodoro() {
    # Check if the timer is already running
    # if [[ -f "$POMODORO_END_TIME_FILE" ]]; then
    #     return
    # fi
    # Calculate the end time and store it in a file
    END_TIME=$(($(date +%s) + POMODORO_DURATION))
    echo $END_TIME > "$POMODORO_END_TIME_FILE"
}

# Function to stop the Pomodoro timer.
stop_pomodoro() {
    # Remove the file to stop the timer
    rm -f "$POMODORO_END_TIME_FILE"
}

# Function to display the status in the tmux status bar.
pomodoro_status() {
    # Check if the timer file exists.
    if [[ -f "$POMODORO_END_TIME_FILE" ]]; then
        # Read the end time from the file.
        END_TIME=$(cat "$POMODORO_END_TIME_FILE")
        CURRENT_TIME=$(date +%s)
        
        # Calculate remaining seconds.
        REMAINING_TIME=$((END_TIME - CURRENT_TIME))

        if [[ "$REMAINING_TIME" -gt 0 ]]; then
            # Format the remaining time as MM:SS
            MINUTES=$((REMAINING_TIME / 60))
            SECONDS=$((REMAINING_TIME % 60))
            printf "🍅 Work for - %02d:%02d" $MINUTES $SECONDS
        elif [[ "$REMAINING_TIME" -gt -$NOTE_DURATION ]]; then
            MINUTES=$(((NOTE_DURATION + REMAINING_TIME) / 60))
            SECONDS=$(((NOTE_DURATION + REMAINING_TIME) % 60))
            printf "🍅 Take Notes for - %02d:%02d" $MINUTES $SECONDS
        else
            # Timer is finished.
            echo "🍅 Take a Break!"
            # You could add a command here to start a break timer, or just let it finish.
        fi
    else
      echo "🍅 Not Started"
    fi
}

# Main script logic to handle different commands passed as arguments.
case "$1" in
    "start")
        start_pomodoro
        ;;
    "stop")
        stop_pomodoro
        ;;
    "status")
        pomodoro_status
        ;;
    *)
        # Default action for the status bar.
        pomodoro_status
        ;;
esac

