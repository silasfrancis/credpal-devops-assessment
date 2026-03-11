#!/bin/bash

# Description:
#   This script is used to retrieve secrets from AWS Secrets Manager and deploy
#   the application using Docker Compose on an EC2 instance. It implements a
#   blue/green deployment strategy to ensure zero downtime by:
#     1. Detecting the currently active target group (blue or green)
#     2. Pulling the latest image to the inactive environment
#     3. Starting the inactive container and health checking it
#     4. Switching the ALB listener to the new target group
#     5. Draining connections from the old container and stopping it
#
#   It is intended to be run as part of a GitHub Actions workflow via AWS SSM.
#
# Usage:
#   bash deploy.sh <blue_tg_arn> <green_tg_arn> <listener_arn>
#
# Arguments:
#   blue_tg_arn    ARN of the blue target group
#   green_tg_arn   ARN of the green target group
#   listener_arn   ARN of the HTTPS ALB listener

set -e

BLUE_TG_ARN=$1
GREEN_TG_ARN=$2
LISTENER_ARN=$3

echo ">>> Fetching secrets..."
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id node_js_app_secrets \
  --query SecretString \
  --output text)

export POSTGRES_DB=$(echo $SECRET | jq -r .POSTGRES_DB)
export POSTGRES_USER=$(echo $SECRET | jq -r .POSTGRES_USER)
export POSTGRES_PASSWORD=$(echo $SECRET | jq -r .POSTGRES_PASSWORD)

cd /app

echo ">>> Detecting active target group..."
CURRENT_TG_ARN=$(aws elbv2 describe-listeners \
  --listener-arns $LISTENER_ARN \
  --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
  --output text)

if [ "$CURRENT_TG_ARN" == "$BLUE_TG_ARN" ]; then
  ACTIVE="blue"
  INACTIVE="green"
  NEW_TG_ARN=$GREEN_TG_ARN
  NEW_PORT=3001
else
  ACTIVE="green"
  INACTIVE="blue"
  NEW_TG_ARN=$BLUE_TG_ARN
  NEW_PORT=3000
fi

echo ">>> Active: $ACTIVE → Deploying to: $INACTIVE"

echo ">>> Pulling latest image..."
docker compose pull app_$INACTIVE

echo ">>> Starting $INACTIVE container..."
docker compose up -d app_$INACTIVE

echo ">>> Health checking $INACTIVE on port $NEW_PORT..."
for i in {1..10}; do
  if curl -sf http://localhost:$NEW_PORT/; then
    echo ">>> Health check passed!"
    break
  fi
  if [ $i -eq 10 ]; then
    echo ">>> Health check failed, aborting!"
    docker compose stop app_$INACTIVE
    exit 1
  fi
  echo ">>> Attempt $i failed, retrying in 5s..."
  sleep 5
done

echo ">>> Switching ALB to $INACTIVE..."
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$NEW_TG_ARN

echo ">>> Draining $ACTIVE connections (30s)..."
sleep 30

echo ">>> Stopping $ACTIVE container..."
docker compose stop app_$ACTIVE

echo ">>> Deployment complete! Active: $INACTIVE"