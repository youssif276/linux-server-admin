#!/usr/bin/env bash

set -u

# ==========================================
# Linux Server Administration & Monitoring
# ==========================================

# Project configuration
PROJECT_DIR="$HOME/devops-portfolio/linux-server-admin"
REPORT_DIR="$PROJECT_DIR/reports"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/system.log"

# Create required directories
if ! mkdir -p "$REPORT_DIR" "$LOG_DIR"; then
    echo "ERROR: Could not create project directories."
    exit 1
fi

# Logging function
log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"

    printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$LEVEL" \
        "$MESSAGE" >> "$LOG_FILE"
}

# Record script start
log_message "INFO" "System check started."

# Generate a unique report filename
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
REPORT_FILE="$REPORT_DIR/system-report-$TIMESTAMP.txt"

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
    df -h /

    echo
    echo "5. DISK USAGE STATUS"
    echo "--------------------------------------"

    DISK_USAGE=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    THRESHOLD=80

    if [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
        echo "Current disk usage: ${DISK_USAGE}%"
        echo "Warning threshold: ${THRESHOLD}%"

        if (( DISK_USAGE >= THRESHOLD )); then
            echo "WARNING: Disk usage has reached the threshold!"
        else
            echo "OK: Disk usage is below the threshold."
        fi
    else
        echo "ERROR: Could not determine disk usage."
    fi

    echo
    echo "6. TOP 5 PROCESSES BY MEMORY"
    echo "--------------------------------------"
    ps aux --sort=-%mem | head -n 6

    echo
    echo "======================================"
    echo " SYSTEM CHECK COMPLETED"
    echo "======================================"

} > "$REPORT_FILE"; then

    log_message "INFO" "System report generated successfully: $REPORT_FILE"

else
    log_message "ERROR" "Failed to generate system report."
    echo "ERROR: Failed to generate system report."
    exit 1
fi

# Display the report
echo "System check completed successfully!"
echo
echo "Report saved to:"
echo "$REPORT_FILE"
echo
echo "Report preview:"
echo "--------------------------------------"

cat "$REPORT_FILE"

# Record successful completion
log_message "INFO" "System check completed successfully."
