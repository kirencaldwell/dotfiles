#!/bin/bash
# Function to ensure commit summary cron job is installed

# Check if the cron job already exists
if ! crontab -l 2>/dev/null | grep -q "summarize_commits"; then
    # If it doesn't exist, add it
    (crontab -l 2>/dev/null; echo "55 23 * * * 'summarize_commits'") | crontab -
    echo "Commit summary cron job installed"
else
    echo "Summarize commit cron job already exists"
fi
