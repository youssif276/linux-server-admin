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

# Run a monitoring command and report failures clearly
run_monitoring_command() {
    local DESCRIPTION="$1"
    shift

    if "$@"; then
        return 0
    else
        printf 'WARNING: Failed to collect %s.\n' "$DESCRIPTION"
        log_message "WARNING" "Failed to collect $DESCRIPTION."
        return 1
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
    if ! cat /etc/os-release; then
        echo "WARNING: Could not read operating system information."
        log_message "WARNING" "Could not read /etc/os-release."
    fi

    echo
    echo "2. SYSTEM UPTIME"
    echo "--------------------------------------"
    if ! run_monitoring_command "system uptime" uptime; then
        echo "Uptime information is unavailable."
    fi

    echo
    echo "3. CPU USAGE"
    echo "--------------------------------------"

    if [[ -r /proc/stat ]]; then
        CPU_BEFORE="$(awk '/^cpu / {
            idle = $5 + $6
            total = 0
            for (i = 2; i <= 9; i++) total += $i
            printf "%.0f %.0f\n", total, idle
            exit
        }' /proc/stat)"

        sleep 1

        CPU_AFTER="$(awk '/^cpu / {
            idle = $5 + $6
            total = 0
            for (i = 2; i <= 9; i++) total += $i
            printf "%.0f %.0f\n", total, idle
            exit
        }' /proc/stat)"

        read -r TOTAL_BEFORE IDLE_BEFORE <<< "$CPU_BEFORE"
        read -r TOTAL_AFTER IDLE_AFTER <<< "$CPU_AFTER"

        if [[ "$TOTAL_BEFORE" =~ ^[0-9]+$ &&
              "$IDLE_BEFORE" =~ ^[0-9]+$ &&
              "$TOTAL_AFTER" =~ ^[0-9]+$ &&
              "$IDLE_AFTER" =~ ^[0-9]+$ ]]; then

            TOTAL_DIFF=$((TOTAL_AFTER - TOTAL_BEFORE))
            IDLE_DIFF=$((IDLE_AFTER - IDLE_BEFORE))

            if (( TOTAL_DIFF > 0 &&
                  IDLE_DIFF >= 0 &&
                  IDLE_DIFF <= TOTAL_DIFF )); then

                CPU_USAGE="$(awk \
                    -v total="$TOTAL_DIFF" \
                    -v idle="$IDLE_DIFF" \
                    'BEGIN {
                        printf "%.1f", (total - idle) * 100 / total
                    }')"

                echo "CPU Usage: ${CPU_USAGE}%"
                echo "Measurement Interval: 1 second"
            else
                echo "WARNING: Could not calculate CPU usage."
                log_message "WARNING" "Could not calculate CPU usage."
            fi
        else
            echo "WARNING: Could not read valid CPU statistics."
            log_message "WARNING" "Could not read valid CPU statistics."
        fi
    else
        echo "WARNING: /proc/stat is not available."
        log_message "WARNING" "/proc/stat is not available."
    fi

    echo
        echo "4. MEMORY USAGE"
    echo "--------------------------------------"

    if MEMORY_OUTPUT="$(free -b)"; then
        MEMORY_VALUES="$(printf '%s\n' "$MEMORY_OUTPUT" |
            awk '$1 == "Mem:" {print $2, $3, $7; exit}')"

        read -r MEMORY_TOTAL MEMORY_USED MEMORY_AVAILABLE <<< "$MEMORY_VALUES"

        if [[ "$MEMORY_TOTAL" =~ ^[0-9]+$ &&
              "$MEMORY_USED" =~ ^[0-9]+$ &&
              "$MEMORY_AVAILABLE" =~ ^[0-9]+$ ]] &&
           (( MEMORY_TOTAL > 0 )); then

            MEMORY_USAGE="$(awk \
                -v used="$MEMORY_USED" \
                -v total="$MEMORY_TOTAL" \
                'BEGIN {printf "%.1f", used * 100 / total}')"

            MEMORY_USAGE_INTEGER="${MEMORY_USAGE%.*}"

            echo "Total Memory: $(numfmt --to=iec "$MEMORY_TOTAL")"
            echo "Used Memory: $(numfmt --to=iec "$MEMORY_USED")"
            echo "Available Memory: $(numfmt --to=iec "$MEMORY_AVAILABLE")"
            echo "Memory Usage: ${MEMORY_USAGE}%"
            echo "Warning threshold: ${MEMORY_USAGE_THRESHOLD}%"

            if (( MEMORY_USAGE_INTEGER >= MEMORY_USAGE_THRESHOLD )); then
                echo "WARNING: Memory usage has reached the threshold!"
                log_message "WARNING" \
                    "Memory usage is ${MEMORY_USAGE}%."
            else
                echo "OK: Memory usage is below the threshold."
                log_message "INFO" \
                    "Memory usage is ${MEMORY_USAGE}%."
            fi
        else
            echo "WARNING: Could not parse valid memory statistics."
            log_message "WARNING" "Could not parse valid memory statistics."
        fi
    else
        echo "WARNING: Failed to collect memory usage."
        echo "Memory information is unavailable."
        log_message "WARNING" "Failed to collect memory usage."
    fi

    echo "5. ROOT FILESYSTEM USAGE"
    echo "--------------------------------------"

    if ! run_monitoring_command \
        "filesystem usage" df -h "$DISK_MOUNT_POINT"; then
        echo "Filesystem information is unavailable."
    fi

    echo
    echo "6. DISK USAGE STATUS"
    echo "--------------------------------------"

    if DF_OUTPUT="$(df -P "$DISK_MOUNT_POINT")"; then
        DISK_USAGE="$(printf '%s\n' "$DF_OUTPUT" |
            awk 'NR==2 {gsub(/%/, "", $5); print $5}')"

        if [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
            echo "Mount point: $DISK_MOUNT_POINT"
            echo "Current disk usage: ${DISK_USAGE}%"
            echo "Warning threshold: ${DISK_USAGE_THRESHOLD}%"

            if (( DISK_USAGE >= DISK_USAGE_THRESHOLD )); then
                echo "WARNING: Disk usage has reached the threshold!"
                log_message "WARNING" \
                    "Disk usage is ${DISK_USAGE}% on $DISK_MOUNT_POINT"
            else
                echo "OK: Disk usage is below the threshold."
                log_message "INFO" \
                    "Disk usage is ${DISK_USAGE}% on $DISK_MOUNT_POINT"
            fi
        else
            echo "ERROR: Could not determine disk usage."
            log_message "ERROR" "Could not determine disk usage."
        fi
    else
        echo "ERROR: Failed to read disk usage."
        log_message "ERROR" \
            "Failed to read disk usage for $DISK_MOUNT_POINT"
    fi

    echo
    echo "7. TOP ${TOP_PROCESSES_COUNT} PROCESSES BY MEMORY"
    echo "--------------------------------------"

    if PROCESS_LIST="$(ps aux --sort=-%mem)"; then
        printf '%s\n' "$PROCESS_LIST" |
            head -n "$((TOP_PROCESSES_COUNT + 1))"
    else
        echo "WARNING: Could not collect process information."
        log_message "WARNING" "Could not collect process information."
    fi

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
    printf 'ERROR: Failed to display system report.\n' >&2
    exit 1
fi

# Record successful completion
log_message "INFO" "System check completed successfully."
