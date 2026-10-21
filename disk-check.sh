#!/usr/bin/env bash

set -u

# ==========================================
# Linux Server Administration & Monitoring
# Disk Usage Checker
# ==========================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Load shared configuration
if ! source "$SCRIPT_DIR/config.sh"; then
    printf 'ERROR: Failed to load configuration.\n' >&2
    exit 1
fi

# Logging function
log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"

    if ! printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$LEVEL" \
        "$MESSAGE" >> "$LOG_FILE"; then
        printf 'WARNING: Could not write to log file.\n' >&2
    fi
}

printf '%s\n' \
    "================================" \
    "       DISK USAGE CHECK" \
    "================================"

printf '\nChecking filesystem: %s\n' "$DISK_MOUNT_POINT"

# Check that the mount point exists
if [[ ! -e "$DISK_MOUNT_POINT" ]]; then
    printf 'ERROR: Mount point does not exist: %s\n' "$DISK_MOUNT_POINT" >&2
    log_message "ERROR" "Mount point does not exist: $DISK_MOUNT_POINT"
    exit 1
fi

# Get disk usage
if ! DF_OUTPUT="$(df -P "$DISK_MOUNT_POINT")"; then
    printf 'ERROR: Failed to read disk usage.\n' >&2
    log_message "ERROR" "Failed to read disk usage for $DISK_MOUNT_POINT"
    exit 1
fi

DISK_USAGE="$(printf '%s\n' "$DF_OUTPUT" |
    awk 'NR==2 {gsub(/%/, "", $5); print $5}')"

# Validate disk usage result
if [[ ! "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
    printf 'ERROR: Could not determine disk usage.\n' >&2
    log_message "ERROR" "Could not determine disk usage."
    exit 1
fi

printf 'Current disk usage: %s%%\n' "$DISK_USAGE"
printf 'Warning threshold: %s%%\n' "$DISK_USAGE_THRESHOLD"

# Evaluate disk usage
if (( DISK_USAGE >= DISK_USAGE_THRESHOLD )); then
    printf 'WARNING: Disk usage has reached the threshold!\n'
    log_message "WARNING" \
        "Disk usage is ${DISK_USAGE}% on $DISK_MOUNT_POINT"
else
    printf 'OK: Disk usage is below the threshold.\n'
    log_message "INFO" \
        "Disk usage is ${DISK_USAGE}% on $DISK_MOUNT_POINT"
fi

printf '\nDisk check completed.\n'
