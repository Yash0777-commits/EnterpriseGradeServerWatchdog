#!/bin/bash

# Load external functions and configuration
source "$(dirname "$0")/../../lib/functions.sh"  # Load custom functions (e.g., log_message, send_alert)
source "$(dirname "$0")/../../config/config.sh"  # Load configuration values like thresholds

# Define log directory and file
log_dir="$(dirname "$0")/../../logs"  # Define path for log files
log_file="$log_dir/monitor.log"  # Define log file name
mkdir -p "$log_dir"  # Create the log directory if it doesn't exist

# Get memory statistics (total and used memory in MB)
total_mem=$(free -m | awk '/Mem/ {print $2}')
used_mem=$(free -m | awk '/Mem/ {print $3}')

# Validate memory values
if [[ -z "$total_mem" || -z "$used_mem" || ! "$total_mem" =~ ^[0-9]+$ || ! "$used_mem" =~ ^[0-9]+$ || "$total_mem" -eq 0 ]]; then
    log_message "Error: Unable to retrieve memory usage. Total: '$total_mem', Used: '$used_mem'" "$log_file"  # Log error if invalid value
    exit 1  # Exit the script with error code
fi

# Calculate memory usage percentage
mem_usage=$(( (used_mem * 100) / total_mem ))

# Log the current memory usage
log_message "Memory Usage: $mem_usage%" "$log_file"

# Ensure MEMORY_THRESHOLD is set from config (default to 80 if not set)
: ${MEMORY_THRESHOLD:=80}

# Check if memory usage exceeds the threshold
if (( mem_usage > MEMORY_THRESHOLD )); then
    send_alert "High Memory usage: $mem_usage% (Threshold: ${MEMORY_THRESHOLD}%)"  # Send alert if threshold exceeded
fi
