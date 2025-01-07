#!/bin/bash

log_dir="$(dirname "$0")/../../logs"  # Define path for log files
log_file="$log_dir/alerts.log"  # Define log file name
mkdir -p "$log_dir"

# Function to log a message with a timestamp
log_message() {
  local message="$1"    # The log message passed as the first argument
  local log_file="$2"   # The log file path passed as the second argument
  # Append the message with the current date and time to the log file
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Function to send an alert and log it
send_alert() {
  local message="$1"    # The alert message passed as the first argument
  # Call log_message to append the alert message to the alerts log file
  log_message "$message" "$log_file"
}

# Function to clear the terminal screen
clear_screen() {
    clear  # Clears the terminal display
}
