# Linux Server Administration & Monitoring

## Project Overview

A Bash-based project for basic Linux system administration and monitoring.

The project collects system information, checks disk usage, displays memory-intensive processes, generates timestamped reports, and records execution events.

Tested in Ubuntu running under WSL 2.

## Features

- Operating system and kernel information
- System uptime and load averages
- Memory and swap usage
- Root filesystem usage monitoring
- Configurable disk usage warning threshold
- Top five processes by memory usage
- Timestamped system reports
- Execution logging
- Standalone disk usage checker

## Project Structure

```text
linux-server-admin/
├── system-info.sh
├── disk-check.sh
├── README.md
├── .gitignore
├── logs/
└── reports/
```

## Requirements

- Ubuntu or another Linux distribution
- Bash
- Standard Linux utilities

## Usage

Make the scripts executable:

```bash
chmod +x system-info.sh disk-check.sh
```

Generate a system report:

```bash
./system-info.sh
```

Check disk usage:

```bash
./disk-check.sh
```

View execution logs:

```bash
cat logs/system.log
```

## Configuration

The default disk usage warning threshold is 80%.

## Limitations

- Checks the local system only.
- Monitors the root filesystem.
- Does not currently send alerts or monitor remote servers.
- Tested in Ubuntu under WSL 2.

## Future Improvements

- CPU monitoring
- Improved error handling
- Automated scheduled checks
- Docker integration
- Automated tests

## Author

Add your professional name and contact details before publishing.
