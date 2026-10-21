#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)" || exit 1

trap 'rm -rf "$TEST_DIR"' EXIT

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

# Test 1: Valid configuration
if bash -c 'source "$1"' _ "$SCRIPT_DIR/config.sh"; then
    pass "Valid configuration is accepted"
else
    fail "Valid configuration is accepted"
fi

# Test 2: Invalid threshold
sed 's/^DISK_USAGE_THRESHOLD=80$/DISK_USAGE_THRESHOLD=150/' \
    "$SCRIPT_DIR/config.sh" > "$TEST_DIR/config-invalid-threshold.sh"

if bash -c 'source "$1"' _ "$TEST_DIR/config-invalid-threshold.sh" \
    > "$TEST_DIR/threshold-output.txt" 2>&1; then
    fail "Invalid threshold is rejected"
else
    pass "Invalid threshold is rejected"
fi

# Test 3: Invalid process count
sed 's/^TOP_PROCESSES_COUNT=5$/TOP_PROCESSES_COUNT=0/' \
    "$SCRIPT_DIR/config.sh" > "$TEST_DIR/config-invalid-processes.sh"

if bash -c 'source "$1"' _ "$TEST_DIR/config-invalid-processes.sh" \
    > "$TEST_DIR/process-output.txt" 2>&1; then
    fail "Invalid process count is rejected"
else
    pass "Invalid process count is rejected"
fi

printf '\nPassed: %s\n' "$PASS_COUNT"
printf 'Failed: %s\n' "$FAIL_COUNT"

if (( FAIL_COUNT > 0 )); then
    exit 1
fi

exit 0
