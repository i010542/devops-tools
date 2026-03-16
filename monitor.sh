#!/usr/bin/env bash
# monitor.sh — lightweight service health monitor with alerting
# Usage: ./monitor.sh [service] [threshold_ms]

set -euo pipefail

SERVICE="${1:-http://localhost:8080/health}"
THRESHOLD="${2:-2000}"
LOG_FILE="${LOG_FILE:-/tmp/monitor.log}"

timestamp() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }

check_service() {
    local url="$1"
    local start end elapsed http_code

    start=$(date +%s%3N)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")
    end=$(date +%s%3N)
    elapsed=$((end - start))

    echo "$http_code $elapsed"
}

main() {
    echo "[$(timestamp)] Checking $SERVICE (threshold: ${THRESHOLD}ms)"

    read -r code ms < <(check_service "$SERVICE")

    if [[ "$code" =~ ^2 ]]; then
        status="UP"
    else
        status="DOWN"
    fi

    msg="[$(timestamp)] $status code=$code latency=${ms}ms service=$SERVICE"
    echo "$msg" | tee -a "$LOG_FILE"

    if [[ "$status" == "DOWN" ]] || (( ms > THRESHOLD )); then
        echo "[ALERT] Service degraded: $msg" >&2
        exit 1
    fi
}

main "$@"
