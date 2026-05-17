#!/bin/sh
# Fetches config from Convex, starts hellminer, and pings every 60s for redeploy signals.
# Required env: CONVEX_URL
# Optional env: DEVICE_ID (defaults to hostname)

DEVICE_ID="${DEVICE_ID:-$(hostname)}"
VERSION_FILE="/tmp/vrsc-version"
[ -f "$VERSION_FILE" ] && CURRENT_VERSION=$(cat "$VERSION_FILE") || CURRENT_VERSION=0

fetch_config() {
  curl -sf "$CONVEX_URL/device-config" || { echo "ERROR: Could not fetch config"; exit 1; }
}

start_miner() {
  CONFIG=$(fetch_config)
  WALLET=$(echo "$CONFIG" | jq -r '.wallet')
  POOL=$(echo "$CONFIG"   | jq -r '.pool')
  THREADS=$(echo "$CONFIG" | jq -r '.threads')
  VERSION=$(echo "$CONFIG" | jq -r '.version')
  WORKER="node-${DEVICE_ID}"

  [ "$THREADS" = "0" ] || [ -z "$THREADS" ] && THREADS=$(nproc --all)

  echo "Starting hellminer: wallet=$WALLET worker=$WORKER threads=$THREADS"
  ./hellminer -c "$POOL" -u "$WALLET.$WORKER" -p x --cpu "$THREADS" &
  MINER_PID=$!
  echo "$VERSION" > "$VERSION_FILE"
  CURRENT_VERSION=$VERSION
}

start_miner

# Ping loop — checks for redeploy every 60s
while true; do
  sleep 60

  RESPONSE=$(curl -sf -X POST "$CONVEX_URL/ping" \
    -H "Content-Type: application/json" \
    -d "{\"deviceId\":\"$DEVICE_ID\",\"currentVersion\":$CURRENT_VERSION}" 2>/dev/null)

  [ -z "$RESPONSE" ] && continue

  REDEPLOY=$(echo "$RESPONSE" | jq -r '.redeploy')

  if [ "$REDEPLOY" = "true" ]; then
    echo "New config detected — restarting miner..."
    kill "$MINER_PID" 2>/dev/null
    wait "$MINER_PID" 2>/dev/null
    start_miner
  fi
done
