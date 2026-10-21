#!/usr/bin/env bash

# ==========================================
# Linux Server Administration & Monitoring
# Shared Configuration
# ==========================================

# Project directories
PROJECT_DIR="$HOME/devops-portfolio/linux-server-admin"
REPORT_DIR="$PROJECT_DIR/reports"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/system.log"

# Monitoring configuration
DISK_USAGE_THRESHOLD=80
DISK_MOUNT_POINT="/"

# Display configuration
TOP_PROCESSES_COUNT=5

# Create required directories
if ! mkdir -p "$REPORT_DIR" "$LOG_DIR"; then
    printf 'ERROR: Could not create project directories.\n' >&2
    return 1 2>/dev/null || exit 1
fi

# Validate disk usage threshold
if [[ ! "$DISK_USAGE_THRESHOLD" =~ ^[0-9]+$ ]] ||
   (( DISK_USAGE_THRESHOLD < 1 || DISK_USAGE_THRESHOLD > 100 )); then
    printf 'ERROR: DISK_USAGE_THRESHOLD must be between 1 and 100.\n' >&2
    return 1 2>/dev/null || exit 1
fi

# Validate process count
if [[ ! "$TOP_PROCESSES_COUNT" =~ ^[0-9]+$ ]] ||
   (( TOP_PROCESSES_COUNT < 1 )); then
    printf 'ERROR: TOP_PROCESSES_COUNT must be a positive integer.\n' >&2
    return 1 2>/dev/null || exit 1
fi
