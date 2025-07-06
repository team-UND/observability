#!/bin/bash
set -euo pipefail

HEALTH_CHECK_PORT=9090
HEALTH_CHECK_URL="http://localhost:$HEALTH_CHECK_PORT/-/healthy"
MAX_RETRIES=30
SLEEP_SECONDS=5

echo "Performing health check on $HEALTH_CHECK_URL..."

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i/$MAX_RETRIES..."

  HEALTH_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" --max-time $SLEEP_SECONDS $HEALTH_CHECK_URL) || HEALTH_STATUS="000"

  if [ "$HEALTH_STATUS" -eq 200 ]; then
    echo "Health check successful. Prometheus is healthy."
    exit 0
  fi

  echo "Health check failed with HTTP status: $HEALTH_STATUS. Retrying in $SLEEP_SECONDS seconds..."
  sleep $SLEEP_SECONDS
done

echo "Health check failed after $MAX_RETRIES attempts."
echo "Please check the container logs for errors: docker logs prometheus"
exit 1
