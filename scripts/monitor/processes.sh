#!/bin/bash

# Load external functions and configuration
source "$(dirname "$0")/../../lib/functions.sh"  # Load custom functions (e.g., log_message, send_alert)
source "$(dirname "$0")/../../config/config.sh"  # Load configuration values like thresholds

# Define log directory and file
log_dir="$(dirname "$0")/../../logs"  # Define path for log files
log_file="$log_dir/monitor.log"  # Define log file name
mkdir -p "$log_dir"  # Create the log directory if it doesn't exist

# Ensure bc is installed (needed for floating-point arithmetic)
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' is required for floating-point arithmetic but is not installed." >&2
    exit 1
fi

# Get top processes by CPU usage and retrieve the top 10 processes, skipping header
top_processes=$(ps aux --sort=-%cpu | tail -n +2 | head -n 10)  # Skip the first line with `tail -n +2`

# Validate output
if [[ -z "$top_processes" ]]; then
    log_message "Error: Unable to retrieve top processes." "$log_file"  # Log error if unable to retrieve processes
    exit 1  # Exit the script with error code
fi

# Log the top processes
log_message "Top Processes by CPU Usage:\n$top_processes" "$log_file"

# Ensure CPU_PROCESS_THRESHOLD is set from config (default to 50 if not set)
: ${CPU_PROCESS_THRESHOLD:=50}

# Loop through the top processes and check if CPU usage exceeds the threshold
echo "$top_processes" | while read -r process; do
    # Extract CPU usage and process name reliably
    process_cpu=$(echo "$process" | awk '{print $3}')  # Extract CPU usage percentage of the process
    process_name=$(echo "$process" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')  # Extract full command name reliably

    # Check if CPU usage is a valid number
    if [[ ! "$process_cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        log_message "Error: Invalid CPU usage value for process '$process_name'. Value: '$process_cpu'" "$log_file"
        continue  # Skip invalid entries
    fi

    # Check if process CPU usage exceeds threshold
    if (( $(echo "$process_cpu > $CPU_PROCESS_THRESHOLD" | bc -l) )); then
        send_alert "High CPU Usage by Process: $process_name - $process_cpu% CPU (Threshold: ${CPU_PROCESS_THRESHOLD}%)"  # Send alert if threshold exceeded
    fi
done
