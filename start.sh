#!/bin/sh
# Fetches mining config from Convex, then launches hellminer.
# Required env: CONVEX_URL
# Optional env: WORKER_NUMBER (defaults to 1)

CONFIG=$(curl -sf "$CONVEX_URL/device-config") || {
  echo "ERROR: Could not fetch config from $CONVEX_URL/device-config"
  exit 1
}

WALLET=$(echo "$CONFIG" | jq -r '.wallet')
POOL=$(echo "$CONFIG" | jq -r '.pool')
THREADS=$(echo "$CONFIG" | jq -r '.threads')
WORKER_NUMBER="${WORKER_NUMBER:-1}"
WORKER="node-${WORKER_NUMBER}"

# Auto-detect CPU count when threads is 0 or empty
if [ "$THREADS" = "0" ] || [ -z "$THREADS" ]; then
  THREADS=$(nproc --all)
fi

exec ./hellminer -c "$POOL" -u "$WALLET.$WORKER" -p x --cpu "$THREADS"
