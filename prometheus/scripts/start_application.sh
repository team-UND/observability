#!/bin/bash
set -euo pipefail

export AWS_REGION="ap-northeast-2"
export ECR_REGISTRY="116541189059.dkr.ecr.ap-northeast-2.amazonaws.com"
export REPOSITORY_NAME="beforegoing-prometheus"
export IMAGE_TAG="latest"
export CONTAINER_NAME="prometheus"
export APP_PORT=9090

echo "Starting Prometheus application container..."

echo "Pulling latest image: $ECR_REGISTRY/$REPOSITORY_NAME:$IMAGE_TAG"
docker pull $ECR_REGISTRY/$REPOSITORY_NAME:$IMAGE_TAG

echo "Starting new container: $CONTAINER_NAME"
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $APP_PORT:$APP_PORT \
  -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /opt/prometheus/data:/prometheus \
  -e TZ=Asia/Seoul \
  $ECR_REGISTRY/$REPOSITORY_NAME:$IMAGE_TAG

echo "Checking container status..."
for i in {1..30}; do
    if docker ps --filter name=$CONTAINER_NAME --filter status=running -q | grep -q .; then
        echo "Container started successfully after $i attempts"
        break
    elif [ $i -eq 30 ]; then
        echo "Container failed to start after 30 attempts"
        docker logs $CONTAINER_NAME
        exit 1
    else
        echo "Attempt $i/30: Container not ready yet, waiting..."
        sleep 3
    fi
done

echo "Container startup completed successfully!"
