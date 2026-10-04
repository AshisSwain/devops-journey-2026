#!/usr/bin/env bash

set -euo pipefail

readonly API_CONTAINER="devops-api"
readonly POSTGRES_CONTAINER="devops-postgres"

pass() {
	echo "[pass] $1"
 }


fail() {
	echo "[fail] $1"
}


check_ssh() {
	if systemctl is-active --quiet ssh; then
		pass "SSH service"
		return 0
	else
		fail "SSH service"
		return 1
	fi
}

check_docker() {
	if systemctl is-active --quiet docker; then
		pass "Docker service"
		return 0
	else
		fail "Docker service"
		return 1
	fi
}

check_container() {
	local container_name="$1"
	local status

	status="$(docker inspect -f '{{.State.Running}}' "${container_name}" 2>/dev/null || echo "false")"

	if [[ "${status}" == "true" ]]; then
		pass "${container_name}"
		return 0
	else
		fail "${container_name}"
		return 1
	fi
}

main() {
	local failures=0

	check_ssh || ((failures++))
	check_docker || ((failures++))
	check_container "${API_CONTAINER}" || ((failures++))
	check_container "${POSTGRES_CONTAINER}" || ((failures++))

	if (( failures > 0 ));then
		echo "Health check FAILED: $failures check(s) failed"
		return 1
	fi

	echo "Health check PASSED"
	return 0
}

main "$@"



























       
