#!/bin/bash

# Configuration: Define the thresholds for monitoring various system metrics

# CPU usage threshold percentage (default: 80%)
: ${CPU_THRESHOLD:=80} # Default to 80% if not set via config/environment

# Disk usage threshold percentage (default: 90%)
: ${DISK_THRESHOLD:=80} # Default to 90% if not set via config/environment

# Memory usage threshold percentage (default: 80%)
: ${MEMORY_THRESHOLD:=80} # Default to 80% if not set via config/environment

# Traffic threshold for network monitoring in bytes (default: 1 GB)
: ${TRAFFIC_THRESHOLD:=1073741824}  # 1 GB in bytes (default)

# Ensure that all threshold values are numeric and fall within the valid range (0-100)
# Check if the CPU threshold is a valid number between 0 and 100
if [[ ! "$CPU_THRESHOLD" =~ ^[0-9]+$ || "$CPU_THRESHOLD" -lt 0 || "$CPU_THRESHOLD" -gt 100 ]]; then
    echo "Error: Invalid CPU_THRESHOLD value: $CPU_THRESHOLD. Must be a number between 0 and 100." >&2  # Print error message to stderr
    exit 1  # Exit with error status
fi

# Check if the disk threshold is a valid number between 0 and 100
if [[ ! "$DISK_THRESHOLD" =~ ^[0-9]+$ || "$DISK_THRESHOLD" -lt 0 || "$DISK_THRESHOLD" -gt 100 ]]; then
    echo "Error: Invalid DISK_THRESHOLD value: $DISK_THRESHOLD. Must be a number between 0 and 100." >&2  # Print error message to stderr
    exit 1  # Exit with error status
fi

# Check if the memory threshold is a valid number between 0 and 100
if [[ ! "$MEMORY_THRESHOLD" =~ ^[0-9]+$ || "$MEMORY_THRESHOLD" -lt 0 || "$MEMORY_THRESHOLD" -gt 100 ]]; then
    echo "Error: Invalid MEMORY_THRESHOLD value: $MEMORY_THRESHOLD. Must be a number between 0 and 100." >&2  # Print error message to stderr
    exit 1  # Exit with error status
fi
