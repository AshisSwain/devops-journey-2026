#!/usr/bin/env bash

set -euo pipefail

SERVICES=("ssh" "docker")
CONTAINERS=("devops-api" "devops-postgres")

pass() {
    echo "[PASS] $1"
}

fail() {
    echo "[FAIL] $1"
}

check_service() {
    local service="$1"

    if systemctl is-active --quiet "$service"; then
        pass "Service $service"
        return 0
    else
        fail "Service $service"
        return 1
    fi
}

check_container() {
    local container="$1"

    if docker ps --format '{{.Names}}' | grep -Fxq "$container"; then
        pass "Container $container"
        return 0
    else
        fail "Container $container"
        return 1
    fi
}

main() {
    local failures=0

    echo "===== SERVICE HEALTH CHECK ====="

    for service in "${SERVICES[@]}"; do
        check_service "$service" || failures=$((failures + 1))
    done

    echo

    echo "===== CONTAINER HEALTH CHECK ====="

    for container in "${CONTAINERS[@]}"; do
        check_container "$container" || failures=$((failures + 1))
    done

    echo

    if (( failures > 0 )); then
        echo "Health check FAILED: $failures check(s) failed"
        return 1
    fi

    echo "Health check PASSED"
    return 0
}

main "$@"
