#!/usr/bin/env bash

set -u

THRESHOLD=80
MOUNT_POINT="/"

echo "================================"
echo "       DISK USAGE CHECK"
echo "================================"

echo
echo "Checking filesystem: $MOUNT_POINT"

DISK_USAGE=$(df -P "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if [[ ! "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not determine disk usage."
    exit 1
fi

echo "Current disk usage: ${DISK_USAGE}%"
echo "Warning threshold: ${THRESHOLD}%"

if (( DISK_USAGE >= THRESHOLD )); then
    echo "WARNING: Disk usage has reached the threshold!"
else
    echo "OK: Disk usage is below the threshold."
fi

echo
echo "Disk check completed."
