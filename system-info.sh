#!/usr/bin/env bash

set -u

# ==========================================
# Linux Server Administration & Monitoring
# System Information & Monitoring
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

# Record script start
log_message "INFO" "System check started."

# Generate a timestamped report filename
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
REPORT_FILE="$REPORT_DIR/system-report-$TIMESTAMP.txt"

# Avoid overwriting an existing report
if [[ -e "$REPORT_FILE" ]]; then
    printf 'ERROR: Report file already exists: %s\n' "$REPORT_FILE" >&2
    log_message "ERROR" "Report filename collision: $REPORT_FILE"
    exit 1
fi

log_message "INFO" "Generating system report."

# Collect system information and generate report
if {
    echo "======================================"
    echo " LINUX SERVER INFORMATION & MONITORING"
    echo "======================================"

    echo
    echo "Report Date: $(date)"
    echo "Hostname: $(hostname)"

    echo
    echo "1. SYSTEM INFORMATION"
    echo "--------------------------------------"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Operating System:"
    cat /etc/os-release

    echo
    echo "2. SYSTEM UPTIME"
    echo "--------------------------------------"
    uptime

    echo
    echo "3. MEMORY USAGE"
    echo "--------------------------------------"
    free -h

    echo
    echo "4. ROOT FILESYSTEM USAGE"
    echo "--------------------------------------"
    df -h "$DISK_MOUNT_POINT"

    echo
    echo "5. DISK USAGE STATUS"
    echo "--------------------------------------"

    DF_OUTPUT="$(df -P "$DISK_MOUNT_POINT")"
    DISK_USAGE="$(printf '%s\n' "$DF_OUTPUT" |
        awk 'NR==2 {gsub(/%/, "", $5); print $5}')"

    if [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
        echo "Mount point: $DISK_MOUNT_POINT"
        echo "Current disk usage: ${DISK_USAGE}%"
        echo "Warning threshold: ${DISK_USAGE_THRESHOLD}%"

        if (( DISK_USAGE >= DISK_USAGE_THRESHOLD )); then
            echo "WARNING: Disk usage has reached the threshold!"
        else
            echo "OK: Disk usage is below the threshold."
        fi
    else
        echo "ERROR: Could not determine disk usage."
    fi

    echo
    echo "6. TOP ${TOP_PROCESSES_COUNT} PROCESSES BY MEMORY"
    echo "--------------------------------------"
    ps aux --sort=-%mem | head -n "$((TOP_PROCESSES_COUNT + 1))"

    echo
    echo "======================================"
    echo " SYSTEM CHECK COMPLETED"
    echo "======================================"

} > "$REPORT_FILE"; then

    log_message "INFO" "System report generated successfully: $REPORT_FILE"

else
    log_message "ERROR" "Failed to generate system report."
    printf 'ERROR: Failed to generate system report.\n' >&2
    exit 1
fi

# Display report location
printf 'System check completed successfully!\n\n'
printf 'Report saved to:\n%s\n\n' "$REPORT_FILE"
printf 'Report preview:\n'
printf '%s\n' '--------------------------------------'

if ! cat "$REPORT_FILE"; then
    log_message "ERROR" "Failed to display system report: $REPORT_FILE"
    exit 1
fi

# Record successful completion
log_message "INFO" "System check completed successfully."
