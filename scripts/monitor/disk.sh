#!/bin/bash

# Load external functions and configuration
source "$(dirname "$0")/../../lib/functions.sh"  # Load custom functions (e.g., log_message, send_alert)
source "$(dirname "$0")/../../config/config.sh"  # Load configuration values like thresholds

# Define log directory and file
log_dir="$(dirname "$0")/../../logs"  # Define path for log files
log_file="$log_dir/monitor.log"  # Define log file name
mkdir -p "$log_dir"  # Create the log directory if it doesn't exist

# Get disk usage for the root partition and remove the '%' sign
disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | sed 's/%//')

# Validate disk usage value
if [[ -z "$disk_usage" || ! "$disk_usage" =~ ^[0-9]+$ ]]; then
    log_message "Error: Unable to retrieve disk usage. Value: '$disk_usage'" "$log_file"  # Log error if invalid value
    exit 1  # Exit the script with error code
fi

# Log the current disk usage
log_message "Disk Usage: $disk_usage%" "$log_file"

# Ensure DISK_THRESHOLD is set from config (default to 80 if not set)
: ${DISK_THRESHOLD:=80}

# Check if disk usage exceeds the threshold
if (( disk_usage > DISK_THRESHOLD )); then
    send_alert "High Disk usage: $disk_usage% (Threshold: ${DISK_THRESHOLD}%)"  # Send alert if threshold exceeded
fi
