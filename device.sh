#!/bin/bash
CONVEX_URL="https://quixotic-minnow-62.eu-west-1.convex.site"
DEVICE_ID="${DEVICE_ID:-$(hostname)}"
VERSION_FILE="/etc/vrsc-version"
WORKER_FILE="/etc/vrsc-worker"
CONTAINER_NAME="vrsc-miner"

[ -f "$VERSION_FILE" ] && CURRENT_VERSION=$(cat "$VERSION_FILE") || CURRENT_VERSION=0
[ -f "$WORKER_FILE" ] && WORKER_NUMBER=$(cat "$WORKER_FILE") || WORKER_NUMBER=0

while true; do
  RESPONSE=$(curl -s -X POST "$CONVEX_URL/ping" \
    -H "Content-Type: application/json" \
    -d "{\"deviceId\": \"$DEVICE_ID\", \"currentVersion\": $CURRENT_VERSION}")

  REDEPLOY=$(echo "$RESPONSE" | jq -r '.redeploy')
  VERSION=$(echo "$RESPONSE" | jq -r '.version')
  WORKER_NUMBER=$(echo "$RESPONSE" | jq -r '.workerNumber')

  if [ "$REDEPLOY" = "true" ]; then
    docker stop "$CONTAINER_NAME" 2>/dev/null
    docker rm "$CONTAINER_NAME" 2>/dev/null
    docker run -d \
      --name "$CONTAINER_NAME" \
      --restart unless-stopped \
      -e CONVEX_URL="$CONVEX_URL" \
      -e WORKER_NUMBER="$WORKER_NUMBER" \
      vrsc-miner

    echo "$VERSION" > "$VERSION_FILE"
    echo "$WORKER_NUMBER" > "$WORKER_FILE"
    CURRENT_VERSION=$VERSION
  fi

  sleep 60
done
