#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR" || exit 1

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    printf 'PASS: %s\n' "$1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

printf '%s\n' "======================================"
printf '%s\n' " Linux Monitoring Automated Tests"
printf '%s\n' "======================================"
printf '\n'

# Test 1: Bash syntax
if bash -n config.sh system-info.sh disk-check.sh; then
    pass "Bash syntax validation"
else
    fail "Bash syntax validation"
fi

# Test 2: Configuration file exists
if [[ -f config.sh ]]; then
    pass "Configuration file exists"
else
    fail "Configuration file exists"
fi

# Test 3: Required configuration values
if grep -q '^DISK_USAGE_THRESHOLD=80$' config.sh &&
   grep -q '^DISK_MOUNT_POINT="/"$' config.sh &&
   grep -q '^TOP_PROCESSES_COUNT=5$' config.sh; then
    pass "Default monitoring configuration"
else
    fail "Default monitoring configuration"
fi

# Test 4: Disk checker
if ./disk-check.sh > /tmp/disk-check-test.log 2>&1; then
    if grep -Eq 'Current disk usage: [0-9]+%' /tmp/disk-check-test.log; then
        pass "Disk usage check"
    else
        fail "Disk usage check output"
    fi
else
    fail "Disk usage check execution"
fi

# Test 5: System report generation
if ./system-info.sh > /tmp/system-info-test.log 2>&1; then
    REPORT_PATH="$(sed -n '/^Report saved to:$/ { n; p; }' /tmp/system-info-test.log)"

    if [[ -n "$REPORT_PATH" && -f "$REPORT_PATH" ]]; then
        pass "System report generation"

        # Test 6: CPU section
        if grep -q 'CPU USAGE' "$REPORT_PATH"; then
            pass "CPU monitoring section"
        else
            fail "CPU monitoring section"
        fi

        # Test 7: Memory section
        if grep -q 'MEMORY USAGE' "$REPORT_PATH"; then
            pass "Memory monitoring section"
        else
            fail "Memory monitoring section"
        fi

        # Test 8: Disk section
        if grep -q 'DISK USAGE STATUS' "$REPORT_PATH"; then
            pass "Disk monitoring section"
        else
            fail "Disk monitoring section"
        fi
    else
        fail "System report file was not found"
        cat /tmp/system-info-test.log
    fi
else
    fail "System report generation"
    cat /tmp/system-info-test.log
fi

# Test 9: Logging
if [[ -f logs/system.log ]] &&
   grep -q 'System check started.' logs/system.log; then
    pass "System event logging"
else
    fail "System event logging"
fi

printf '\n'
printf '%s\n' "======================================"
printf 'Passed: %s\n' "$PASS_COUNT"
printf 'Failed: %s\n' "$FAIL_COUNT"
printf '%s\n' "======================================"

if (( FAIL_COUNT > 0 )); then
    exit 1
fi

exit 0
