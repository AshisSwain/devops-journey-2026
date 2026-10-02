#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly DISK_THRESHOLD=80
readonly MEMORY_THRESHOLD=80

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

check_disk() {
    local usage

    usage="$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')"

    if (( usage >= DISK_THRESHOLD )); then
        log "WARNING: Root filesystem usage is ${usage}%"
        return 1
    fi

    log "PASS: Root filesystem usage is ${usage}%"
}

check_ssh() {
    if systemctl is-active --quiet ssh; then
        log "PASS: SSH service is running"
    else
        log "FAIL: SSH service is not running"
        return 1
    fi
}

show_system_info() {
    log "Hostname: $(hostname)"
    log "Kernel: $(uname -r)"
    log "Uptime: $(uptime -p)"
    log "IP addresses:"
    ip -br addr
}

main() {
    log "Starting $SCRIPT_NAME"

    show_system_info

    local failures=0

    check_disk || failures=$((failures + 1))
    check_ssh || failures=$((failures + 1))

    if (( failures > 0 )); then
        log "Health check FAILED: ${failures} check(s) failed"
        return 1
    fi

    log "Health check PASSED"
}

main "$@"

