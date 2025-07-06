#!/bin/bash
set -euo pipefail

export AWS_DEFAULT_REGION=ap-northeast-2
export ECR_REGISTRY="116541189059.dkr.ecr.ap-northeast-2.amazonaws.com"
export APP_NAME="prometheus"

echo "Preparing deployment environment..."

echo "Starting Docker service..."
if ! systemctl is-active --quiet docker; then
    systemctl start docker
fi
systemctl enable docker

echo "Waiting for Docker to be ready..."
timeout 30 bash -c 'until docker info >/dev/null 2>&1; do sleep 1; done'

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "Cleaning up existing containers..."
if [ "$(docker ps -aq)" ]; then
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
fi

echo "Cleaning up old Docker images..."
docker image prune -f
docker system prune -f --volumes

echo "Creating application directories..."
mkdir -p /opt/$APP_NAME/data

echo "Setting permissions for Prometheus data directory..."
# The official Prometheus image runs as the 'nobody' user (UID 65534) which needs write access.
chown 65534:65534 /opt/$APP_NAME/data

echo "Environment prepared successfully"
