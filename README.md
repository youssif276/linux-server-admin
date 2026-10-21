# Linux Server Administration & Monitoring

## Project Overview

A Linux system administration and monitoring project built with Bash. It
collects system information, monitors CPU and memory usage, checks
filesystem capacity, records execution events, and generates timestamped
reports.

The project focuses on reusable configuration, input validation, error
handling, and automated testing.

**Environment:** Ubuntu 26.04 LTS running under WSL 2.

## Features

-   Operating system, kernel, and architecture information
-   System uptime and load averages
-   CPU usage monitoring
-   Memory and swap information
-   Configurable memory usage warning threshold
-   Filesystem usage monitoring with a configurable warning threshold
-   Configurable filesystem mount point
-   Top memory-consuming processes
-   Timestamped system reports
-   Execution logs for monitoring events and errors
-   Standalone disk usage checker
-   Shared configuration through `config.sh`
-   Configuration validation
-   Error handling for selected monitoring failures
-   Automated tests for monitoring and configuration

## Project Structure

``` text
linux-server-admin/
|-- config.sh
|-- system-info.sh
|-- disk-check.sh
|-- README.md
|-- .gitignore
|-- tests/
|   |-- test-monitoring.sh
|   `-- test-config.sh
|-- logs/
`-- reports/
```

Reports are generated when the monitoring script runs. Log and report
files may not exist in a fresh copy until the scripts are executed.

## Requirements

-   Linux or Ubuntu under WSL 2
-   Bash
-   Python 3 for the automated test scripts
-   Standard Linux command-line utilities

## Installation

If the project is already on your computer, open the terminal and
navigate to the project directory:

``` bash
cd ~/devops-portfolio/linux-server-admin
```

Make the scripts executable:

``` bash
chmod +x config.sh system-info.sh disk-check.sh
chmod +x tests/test-monitoring.sh tests/test-config.sh
```

## Usage

### Generate a System Report

``` bash
./system-info.sh
```

The script collects system information, monitors resource usage, and
generates a timestamped report in the `reports/` directory.

### Check Disk Usage

``` bash
./disk-check.sh
```

The script checks the configured filesystem and reports its usage
status.

### View Reports

List available reports:

``` bash
ls -lt reports/
```

Display the latest report:

``` bash
latest_report=$(ls -1t reports/system-report-*.txt 2>/dev/null | head -n 1)
if [ -n "$latest_report" ]; then
    cat "$latest_report"
else
    echo "No system reports found. Run ./system-info.sh first."
fi
```

### View Execution Logs

``` bash
cat logs/system.log
```

### Run Automated Tests

Run the monitoring tests:

``` bash
./tests/test-monitoring.sh
```

Run the configuration tests:

``` bash
./tests/test-config.sh
```

## Configuration

Project settings are managed in `config.sh`.

  -----------------------------------------------------------------------------
  Setting                                         Default Description
  -------------------------- ---------------------------- ---------------------
  `DISK_USAGE_THRESHOLD`                             `80` Disk usage warning
                                                          threshold in percent

  `DISK_MOUNT_POINT`                                  `/` Filesystem mount
                                                          point to monitor

  `MEMORY_USAGE_THRESHOLD`                           `80` Memory usage warning
                                                          threshold in percent

  `TOP_PROCESSES_COUNT`                               `5` Number of top
                                                          memory-consuming
                                                          processes to display
  -----------------------------------------------------------------------------

Threshold values must be integers between 1 and 100. The process count
must be a positive integer.

To change a setting, edit its value in `config.sh` and save the file.

## Error Handling

The monitoring scripts include error handling for selected monitoring
failures.

When memory information cannot be collected, the report records a
warning and indicates that memory information is unavailable. Other
monitoring sections can continue when an individual collection step
fails.

The project includes simulated failure tests to check warning messages,
log entries, and continued execution of other monitoring sections.

## Testing

The automated tests cover:

-   Bash syntax validation
-   Configuration availability and default values
-   Rejection of invalid disk and memory thresholds
-   Rejection of invalid process counts
-   Disk monitoring behavior
-   System report generation
-   CPU, memory, and disk report sections
-   Memory usage percentage and warning threshold
-   Execution logging
-   Selected monitoring error paths

The tests help detect regressions when scripts or configuration are
changed.

## Limitations

-   Monitors the local Linux environment.
-   The default filesystem mount point is `/`.
-   External notifications and alert delivery are not implemented.
-   Tested on Ubuntu under WSL 2; behavior may differ on other Linux
    distributions.
-   WSL 2 is a learning and development environment, not a replacement
    for testing on a production Linux server.

## Future Improvements

-   Schedule monitoring with cron or systemd timers
-   Add email or external alert integrations
-   Monitor multiple filesystems
-   Add Docker-based deployment and testing
-   Integrate automated tests into a CI pipeline
-   Extend monitoring and recovery tests

## Skills Demonstrated

-   Linux command-line administration
-   Bash scripting
-   System resource monitoring
-   Configuration validation
-   Logging and error handling
-   Automated testing
-   Technical documentation
-   Git version control

## Author

**Youssif Nader**

Linux Server Administration & Monitoring project.
