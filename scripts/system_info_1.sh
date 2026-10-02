#!/usr/bin/env bash

set -euo pipefail

readonly DISK_THRESHOLD=80
readonly MEMORY_THRESHOLD=80

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

check_disk() {
	local usage


	usage="$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')"

	if (( usage >= DISK_THRESHOLD )); then
		log "WARNING: Root filesystem usages is ${usage}%"
		return 1
	fi

	log "PASS: Root filesystem usages is ${usage}%"
}

check_memory() {
	local usage


	usage="$(free | awk '/Mem:/ {print int($3/$2*100)}')"

	if (( usage >= MEMORY_THRESHOLD )); then
		log "WARNING: Total memory usages is ${usage}%"
		return 1
	fi

	log "PASS: Total memory usages is ${usage}%"
}

check_ssh() {
	if systemctl is-active --quiet ssh; then
		log "PASS: SSH server is running"
	else
		log "FAIL: SSH service is not running"
	return 1
	fi
}


check_docker() { 
        if systemctl is-active --quiet docker; then
                log "PASS: Docker server is running"
        else
                log "FAIL: Docker service is not running"
        return 1
        fi
}

show_system_info() {
	log "Hostname: $(hostname)"
	log "Kernel: $(uname -r)"
	log "Uptime: $(uptime -p)"

	log "Network inerfaces:"
	ip -br addr
}

main() {
	log "Starting Linux health check"

	show_system_info

	local failures=0

	check_disk || failures=$((failures + 1))
	check_memory || failures=$((failures + 1))
	check_ssh || failures=$((failures + 1))
	check_docker || failures=$((failures + 1))

	if (( failures > 0 )); then
		log "Health check FAILED: ${failures} check(s) failed"
		return 1
	fi

	log "Health check PASSED"
}

main "$@"









