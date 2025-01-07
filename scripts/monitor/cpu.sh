#!/bin/bash

# Source external functions and configuration
source "$(dirname "$0")/../../lib/functions.sh"  # Functions for logging and alerting
source "$(dirname "$0")/../../config/config.sh"  # Configuration file with threshold values

# Get the absolute path to the logs directory
LOG_DIR="$(dirname "$0")/../../logs"

# Ensure the log directory exists (creates it if it doesn't)
mkdir -p "$LOG_DIR"

# Path to the log file where the CPU usage will be logged
LOG_FILE="$LOG_DIR/monitor.log"

# Extract CPU idle time using the 'top' command
cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F ',' '{for(i=1; i<=NF; i++) if ($i ~ /id/) print $i}' | awk '{print $1}')

# Validate the extracted CPU idle time: check if it's a valid numeric value
if [[ -z "$cpu_idle" || ! "$cpu_idle" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    # Log the error if the CPU idle time is invalid
    log_message "Error getting CPU usage. Invalid value: $cpu_idle" "$LOG_DIR/monitor.log"
    exit 1  # Exit the script with an error code
fi

# Calculate the CPU usage by subtracting idle time from 100
cpu_usage=$(echo "100 - $cpu_idle" | bc)

# Log the CPU usage
log_message "CPU Usage: $cpu_usage%" "$LOG_DIR/monitor.log"

# Check if CPU usage exceeds the threshold
if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
    # Send an alert if CPU usage exceeds the threshold
    send_alert "High CPU usage: $cpu_usage% (Threshold: ${CPU_THRESHOLD}%)"
fi
