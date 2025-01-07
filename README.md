# EnterpriseGradeServerWatchdog

## Overview
EnterpriseGradeServerWatchdog is a powerful shell script-based tool designed to monitor critical server metrics such as CPU, memory, disk, network traffic, and top processes. The primary objective of this project is to automate server health monitoring by logging key system metrics and sending alerts whenever a predefined threshold is breached. This tool is perfect for administrators who need to ensure the health of their enterprise servers.

---

## Project Structure
The project is organized as follows:

```bash
├── config/
│   └── config.sh           # Configuration file for monitoring thresholds and alerts
├── lib/
│   └── functions.sh        # Shared functions for logging and alerting
├── logs/
│   ├── alerts.log          # Log file for alert messages
│   └── monitor.log         # Combined log file for monitoring outputs
└── scripts/
    ├── main.sh             # Main script to execute all monitoring tasks
    └── monitor/
        ├── cpu.sh          # Script to monitor CPU usage
        ├── disk.sh         # Script to monitor disk usage
        ├── memory.sh       # Script to monitor memory usage
        ├── network.sh      # Script to monitor network traffic
        └── processes.sh    # Script to log top CPU-consuming processes
```

---

## Features

### CPU Usage Monitoring (`cpu.sh`)
Monitors the CPU usage and sends an alert if it exceeds the defined threshold. The default threshold is **80%**.

### Disk Usage Monitoring (`disk.sh`)
Tracks the disk usage on the root partition and sends an alert if it exceeds the specified threshold. The default threshold is **90%**.

### Memory Usage Monitoring (`memory.sh`)
Monitors system memory usage and triggers an alert if the usage exceeds the threshold. The default threshold is **80%**.

### Network Traffic Monitoring (`network.sh`)
Monitors incoming (RX) and outgoing (TX) network traffic on a specified interface. It sends alerts if traffic exceeds the threshold, which is set by default to **1 GB**.

### Top Processes Monitoring (`processes.sh`)
Logs the top CPU-consuming processes and sends an alert if any process exceeds the defined CPU usage threshold (default is **50%**).

---

## Configuration

### Setting Thresholds
All monitoring thresholds are configurable in the `config/config.sh` file. Adjust these settings to suit your server's needs.

#### Example of `config.sh`:
```bash
# CPU usage threshold in percentage (default: 80%)
: ${CPU_THRESHOLD:=80}

# Disk usage threshold in percentage (default: 90%)
: ${DISK_THRESHOLD:=90}

# Memory usage threshold in percentage (default: 80%)
: ${MEMORY_THRESHOLD:=80}

# Traffic threshold for network monitoring in bytes (default: 1 GB)
: ${TRAFFIC_THRESHOLD:=1073741824}  # 1 GB in bytes
```
You can modify these values directly in the configuration file or pass them as environment variables.

---

## Usage Instructions

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone https://github.com/Yash0777-commits/EnterpriseGradeServerWatchdog.git
cd EnterpriseGradeServerWatchdog
```

### 2. Modify the Configuration (Optional)
Adjust the threshold values in `config/config.sh` to match your server's capacity.

### 3. Running the Monitoring Scripts
Execute the main script to start the monitoring process:
```bash
bash scripts/main.sh
```
This script provides an interactive menu with the following options:
- **View Current Resource Usage**: Display real-time system resource consumption.
- **Run Specific Monitoring Scripts**: Run individual monitoring scripts (CPU, memory, disk, network, or processes).
- **View Logs**: Access log files (`monitor.log` and `alerts.log`).

### 4. Log Files
Logs are stored in the `logs/` directory:
- `monitor.log`: Contains detailed log entries of resource usage.
- `alerts.log`: Contains alerts generated when any threshold is exceeded.

### 5. Alerts
Alerts are logged in `alerts.log` and displayed in the console. For example:
```bash
High Disk usage: 92% (Threshold: 90%)
```

---

## Enhancements and Customizations

### Recent Enhancements
- **CPU Usage Alert**: Alerts when CPU usage exceeds the threshold (default: 80%).
- **Network Traffic Monitoring**: Alerts when RX or TX traffic exceeds 1 GB.
- **Top Processes Monitoring**: Logs and alerts for high CPU-consuming processes (default: 50%).

### Interactive Monitoring
The interactive menu in `main.sh` allows users to:
- View real-time resource usage.
- Run specific monitoring scripts for detailed analysis.
- View log files for historical data.

---

## Future Improvements
Potential enhancements for the tool include:
1. **Email or SMS Notifications**: Add support for sending alerts via email or SMS.
2. **Real-Time Monitoring Dashboard**: Develop a web dashboard for visualizing server health.
3. **Performance Reporting**: Generate reports based on historical data for auditing and analysis.

---

## License
EnterpriseGradeServerWatchdog is licensed under the [MIT License](LICENSE). Feel free to fork and contribute to this project.

---

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Make your changes.
3. Submit a pull request.

For significant changes, please open an issue first to discuss your ideas.

---

## Final Thoughts
EnterpriseGradeServerWatchdog helps administrators proactively monitor server health, reduce system failures, and ensure optimal performance. Its extensible design makes it adaptable to diverse environments and requirements.

