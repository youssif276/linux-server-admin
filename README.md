# Linux Server Administration & Monitoring

## Project Overview

A Bash-based Linux system administration and monitoring project designed to collect system information, monitor resource usage, check disk capacity, and maintain execution logs.

The project includes reusable configuration, automated tests, and timestamped system reports.

Tested on Ubuntu running under WSL 2.

## Features

* Operating system and kernel information
* System uptime and load averages
* CPU usage monitoring
* Memory and swap usage monitoring
* Root filesystem usage monitoring
* Configurable disk usage warning threshold
* Top processes by memory consumption
* Timestamped system reports
* Execution event logging
* Standalone disk usage checker
* Shared configuration file
* Configuration validation
* Automated tests for monitoring and configuration

## Project Structure

```text
linux-server-admin/
├── config.sh
├── system-info.sh
├── disk-check.sh
├── README.md
├── .gitignore
├── tests/
│   ├── test-monitoring.sh
│   └── test-config.sh
├── logs/
└── reports/
```

## Requirements

* Linux or Ubuntu under WSL 2
* Bash
* Standard Linux command-line utilities

## Installation

Clone the repository or download the project, then enter its directory.

Make the scripts executable:

```bash
chmod +x config.sh system-info.sh disk-check.sh
chmod +x tests/test-monitoring.sh tests/test-config.sh
```

## Usage

### Generate a System Report

```bash
./system-info.sh
```

The script collects system information and generates a timestamped report in the `reports/` directory.

### Check Disk Usage

```bash
./disk-check.sh
```

The script checks the configured filesystem and logs its status.

### View Execution Logs

```bash
cat logs/system.log
```

### Run Automated Tests

Run the monitoring tests:

```bash
./tests/test-monitoring.sh
```

Run the configuration validation tests:

```bash
./tests/test-config.sh
```

## Configuration

Project settings are managed through `config.sh`.

Default settings include:

* Disk usage warning threshold: 80%
* Monitored filesystem: `/`
* Number of top memory-consuming processes: 5

The configuration validates important values before the monitoring scripts proceed.

## Testing

The automated tests cover:

* Bash syntax validation
* Configuration file availability
* Default configuration values
* Disk usage checks
* System report generation
* CPU, memory, and disk monitoring sections
* System event logging
* Valid and invalid configuration values

## Limitations

* Monitors the local Linux environment only.
* Currently checks the configured local filesystem.
* Does not send external alerts.
* Tested on Ubuntu under WSL 2; behavior may vary across Linux distributions.

## Future Improvements

* Scheduled monitoring using cron or systemd timers
* Email or external alert integration
* Docker integration
* Monitoring multiple filesystems
* Improved monitoring and failure-recovery tests
* CI pipeline for automated testing

## Author

Add your professional name and contact details before publishing.
