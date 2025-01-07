#!/bin/bash

# Load external functions and configuration
source "$(dirname "$0")/../../lib/functions.sh"  # Load custom functions (e.g., log_message, send_alert)
source "$(dirname "$0")/../../config/config.sh"  # Load configuration values like thresholds

# Define log directory and file
log_dir="$(dirname "$0")/../../logs"  # Define path for log files
log_file="$log_dir/monitor.log"  # Define log file name
mkdir -p "$log_dir"  # Create the log directory if it doesn't exist

# Determine network interface (default to eth0 if not provided)
interface=${1:-eth0}

# Get network statistics (received and transmitted bytes)
rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null)
tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null)

# Validate network statistics
if [[ -z "$rx_bytes" || -z "$tx_bytes" || ! "$rx_bytes" =~ ^[0-9]+$ || ! "$tx_bytes" =~ ^[0-9]+$ ]]; then
    log_message "Error: Unable to get network stats for interface '$interface'. Check if the interface exists." "$log_file"  # Log error if invalid value
    exit 1  # Exit the script with error code
fi

# Log network statistics
log_message "Interface: $interface, Received Bytes: $rx_bytes, Transmitted Bytes: $tx_bytes" "$log_file"

# Define traffic threshold (1 GB in bytes)
TRAFFIC_THRESHOLD=1073741824  # 1 GB in bytes

# Check if network traffic exceeds the threshold
if [[ "$rx_bytes" -gt "$TRAFFIC_THRESHOLD" || "$tx_bytes" -gt "$TRAFFIC_THRESHOLD" ]]; then
    send_alert "High Network Traffic on $interface. RX: $rx_bytes bytes, TX: $tx_bytes bytes (Threshold: ${TRAFFIC_THRESHOLD} bytes)"  # Send alert if threshold exceeded
fi
