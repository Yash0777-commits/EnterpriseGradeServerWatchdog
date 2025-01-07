#!/bin/bash

# Global variables for threshold values and log directory
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_DIR="../logs"  # Log file directory
LOG_FILE="$LOG_DIR/monitor.log" # Combined log file for all monitoring outputs
ALERTS_FILE="$LOG_DIR/alerts.log"
MONITOR_DIR="./monitor"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Function to log messages to the log file with timestamps
log_message() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Function to log alerts to the alerts file
log_alert() {
  alert_message=$1
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $alert_message" >> "$ALERTS_FILE"
}

# Function to handle errors
handle_error() {
  local error_message="$1"
  log_message "ERROR: $error_message"
  dialog --msgbox "Error: $error_message" 10 30
}

# Function to monitor CPU usage and log alerts
monitor_cpu() {
  cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F ',' '{for(i=1; i<=NF; i++) if ($i ~ /id/) print $i}' | awk '{print $1}')
  if [[ -z "$cpu_idle" || ! "$cpu_idle" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    handle_error "Unable to fetch CPU usage."
    return
  fi

  cpu_usage=$(echo "scale=1; 100 - $cpu_idle" | bc)
  if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
    alert="High CPU Usage: $cpu_usage% (Threshold: $CPU_THRESHOLD%)"
    log_alert "$alert"
  fi
}

# Function to monitor Memory usage and log alerts
monitor_memory() {
  free_output=$(free -m)
  total_mem=$(echo "$free_output" | grep Mem | awk '{print $2}')
  used_mem=$(echo "$free_output" | grep Mem | awk '{print $3}')
  cached_mem=$(echo "$free_output" | grep Mem | awk '{print $6}')
  mem_usage=$(echo "($used_mem - $cached_mem) / $total_mem * 100" | bc -l)

  if (( $(echo "$mem_usage > $MEMORY_THRESHOLD" | bc -l) )); then
    alert="High Memory Usage: $mem_usage% (Threshold: $MEMORY_THRESHOLD%)"
    log_alert "$alert"
  fi
}

# Function to monitor Disk usage and log alerts
monitor_disk() {
  disk_usage=$(df -h / | grep "/" | awk '{print $5}' | sed 's/%//')
  if [[ "$disk_usage" -gt "$DISK_THRESHOLD" ]]; then
    alert="High Disk Usage: $disk_usage% (Threshold: $DISK_THRESHOLD%)"
    log_alert "$alert"
  fi
}

# Function to monitor System Load and log alerts
monitor_system_load() {
  load_avg=$(uptime | awk -F 'load average:' '{ print $2 }' | awk '{ print $1 }')
  load_threshold=4  # Set your desired system load threshold

  if (( $(echo "$load_avg > $load_threshold" | bc -l) )); then
    alert="High System Load: $load_avg (Threshold: $load_threshold)"
    log_alert "$alert"
  fi
}

# Function to monitor Top CPU-consuming processes
monitor_cpu_processes() {
  top_process=$(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 2 | tail -n 1)
  process_pid=$(echo $top_process | awk '{print $1}')
  process_cpu=$(echo $top_process | awk '{print $2}')
  process_name=$(echo $top_process | awk '{print $3}')

  # Log and alert if the top process exceeds 50% CPU usage
  if (( $(echo "$process_cpu > 50" | bc -l) )); then
    alert="High CPU Usage by Process: $process_name (PID: $process_pid) - $process_cpu% CPU"
    log_alert "$alert"
  fi
}

# Function to clear the terminal screen when exiting
clear_screen() {
  clear
}

# Function to show CPU usage
show_cpu_usage() {
  local cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F ',' '{for(i=1; i<=NF; i++) if ($i ~ /id/) print $i}' | awk '{print $1}')
  
  if [[ -z "$cpu_idle" || ! "$cpu_idle" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    handle_error "Unable to fetch CPU usage."
    return
  fi

  local cpu_usage=$(echo "scale=1; 100 - $cpu_idle" | bc)
  dialog --msgbox "Current CPU Usage: $cpu_usage%" 10 30
  log_message "CPU Usage: $cpu_usage%"
}

# Function to show Memory usage
show_memory_usage() {
  local free_output=$(free -m)
  local total_mem=$(echo "$free_output" | grep Mem | awk '{print $2}')
  local used_mem=$(echo "$free_output" | grep Mem | awk '{print $3}')
  local cached_mem=$(echo "$free_output" | grep Mem | awk '{print $6}')
  local mem_usage=$(echo "($used_mem - $cached_mem) / $total_mem * 100" | bc -l)

  dialog --msgbox "Current Memory Usage: $mem_usage%" 10 30
  log_message "Memory Usage: $mem_usage%"
}

# Function to show Disk usage
show_disk_usage() {
  local disk_usage_output=$(df -h /)
  local disk_usage=$(echo "$disk_usage_output" | grep "/" | awk '{print $5}' | sed 's/%//')

  dialog --msgbox "Current Disk Usage: $disk_usage%" 10 30
  log_message "Disk Usage: $disk_usage%"
}

# Function to show System Load
show_system_load() {
  local load_avg=$(uptime | awk -F 'load average:' '{ print $2 }' | awk '{ print $1 }')
  dialog --msgbox "Current System Load: $load_avg" 10 30
  log_message "System Load: $load_avg"
}

# Function to show Top CPU-consuming processes
show_top_cpu_processes() {
  local top_process=$(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 2 | tail -n 1)
  dialog --msgbox "Top CPU Process: $top_process" 10 30
  log_message "Top CPU Process: $top_process"
}

# Function to display the main menu using dialog
show_main_menu() {
  dialog --clear --title "System Monitoring" \
    --menu "Choose an option" 15 50 8 \
    1 "View CPU Usage" \
    2 "View Memory Usage" \
    3 "View Disk Usage" \
    4 "View System Load" \
    5 "View Top CPU Process" \
    6 "Run Monitoring Scripts" \
    7 "View Logs" \
    8 "Exit" 2>/tmp/menu_choice.txt

  local choice=$(< /tmp/menu_choice.txt)
  case $choice in
    1) show_cpu_usage ;;
    2) show_memory_usage ;;
    3) show_disk_usage ;;
    4) show_system_load ;;
    5) show_top_cpu_processes ;;
    6) run_monitoring_scripts ;;
    7) view_logs ;;
    8) clear_screen && exit 0 ;;  # Clear screen and exit
    *) show_main_menu ;;  # Invalid choice, show the menu again
  esac
}

# Function to run monitoring scripts
run_monitoring_scripts() {
  dialog --title "Running Scripts" --infobox "Running monitoring scripts. Please wait..." 10 30
  sleep 2  # Simulate the script running

  for script in "$MONITOR_DIR"/*.sh; do
    if [[ -f "$script" ]]; then
      bash "$script" &
      log_message "Running script: $script"
    else
      handle_error "Script not found: $script"
    fi
  done

  wait
  dialog --msgbox "Monitoring scripts completed!" 10 30
  log_message "Monitoring scripts completed."
}

# Function to view logs
view_logs() {
  if [[ -f "$LOG_FILE" ]]; then
    dialog --title "Viewing Log" --tailbox "$LOG_FILE" 20 50  # View logs with scroll
  else
    handle_error "Log file not found: $LOG_FILE"
  fi
}

# Start the script
while true; do
  show_main_menu  # Continuously show the main menu
done

