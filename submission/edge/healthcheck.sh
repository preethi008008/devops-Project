#!/usr/bin/env bash
#
# healthcheck.sh — Edge device health check script
#

set -euo pipefail

STATUS="healthy"
EXIT_CODE=0

report_status () {
  local check="$1"
  local result="$2"

  if [[ "$result" == "critical" ]]; then
    STATUS="critical"
    EXIT_CODE=2
  elif [[ "$result" == "degraded" && "$STATUS" != "critical" ]]; then
    STATUS="degraded"
    EXIT_CODE=1
  fi

  CHECK_RESULTS["$check"]="$result"
}

declare -A CHECK_RESULTS

# --- Docker daemon ---
if systemctl is-active docker >/dev/null 2>&1; then
  report_status "docker" "ok"
else
  report_status "docker" "critical"
fi

# --- Video ingest container ---
if docker ps --format '{{.Names}}' | grep -q "video-ingest"; then
  report_status "video_ingest_container" "ok"
else
  report_status "video_ingest_container" "critical"
fi

# --- GPU availability ---
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  report_status "gpu" "ok"
else
  report_status "gpu" "degraded"
fi

# --- Disk usage ---
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ "$DISK_USAGE" -lt 85 ]]; then
  report_status "disk_usage" "ok"
elif [[ "$DISK_USAGE" -lt 95 ]]; then
  report_status "disk_usage" "degraded"
else
  report_status "disk_usage" "critical"
fi

# --- NTP synchronization ---
if timedatectl status | grep -q "System clock synchronized: yes"; then
  report_status "ntp_sync" "ok"
else
  report_status "ntp_sync" "degraded"
fi

# --- VPN tunnel check ---
if ip link | grep -q "ipsec\|tun"; then
  report_status "vpn_tunnel" "ok"
else
  report_status "vpn_tunnel" "critical"
fi

# --- Camera subnet connectivity ---
CAMERA_SUBNET="192.168.10.1"
if ping -c 1 -W 1 "$CAMERA_SUBNET" >/dev/null 2>&1; then
  report_status "camera_connectivity" "ok"
else
  report_status "camera_connectivity" "degraded"
fi

# --- Output JSON report ---
echo "{"
echo "  \"overall_status\": \"$STATUS\","
echo "  \"checks\": {"

FIRST=1
for key in "${!CHECK_RESULTS[@]}"; do
  if [[ $FIRST -eq 0 ]]; then
    echo ","
  fi
  echo -n "    \"$key\": \"${CHECK_RESULTS[$key]}\""
  FIRST=0
done

echo ""
echo "  }"
echo "}"

exit $EXIT_CODE