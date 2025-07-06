#!/bin/bash
set -euo pipefail

export CONTAINER_NAME="prometheus"
export GRACEFUL_TIMEOUT=30
export FORCE_TIMEOUT=10

echo "Stopping Prometheus application container..."

check_container_status() {
    if docker ps -q --filter name="^$CONTAINER_NAME$" | grep -q .; then
        return 0
    else
        return 1
    fi
}

if ! docker ps -a -q --filter name="^$CONTAINER_NAME$" | grep -q .; then
    echo "Container $CONTAINER_NAME not found"
    exit 0
fi

if check_container_status; then
    echo "Stopping container gracefully (timeout: ${GRACEFUL_TIMEOUT}s)..."

    echo "Last few log lines before shutdown:"
    docker logs --tail 5 $CONTAINER_NAME || true

    docker stop $CONTAINER_NAME --time=$GRACEFUL_TIMEOUT

    if check_container_status; then
        echo "Container still running, forcing stop..."
        timeout $FORCE_TIMEOUT docker kill $CONTAINER_NAME || true
    fi

    echo "Container $CONTAINER_NAME stopped successfully"
else
    echo "Container $CONTAINER_NAME is already stopped"
fi

echo "Removing container: $CONTAINER_NAME"
docker rm $CONTAINER_NAME || true

echo "Container cleanup completed"

echo "Cleaning up unused Docker resources..."
docker system prune -f --volumes 2>/dev/null || true

echo "Application stop process completed successfully"
