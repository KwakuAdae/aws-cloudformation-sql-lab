#!/usr/bin/env bash
# Step 1: Create (or update) the CloudFormation stack: VPC + Aurora PostgreSQL Serverless v2.
set -euo pipefail
source "$(dirname "$0")/config.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo ">> Validating template..."
aws cloudformation validate-template \
  --template-body "file://${ROOT}/cloudformation/sql-lab.yaml" --region "$AWS_REGION" >/dev/null

echo ">> Deploying stack '${STACK_NAME}' to ${AWS_REGION} (about 10-15 minutes)..."
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "${ROOT}/cloudformation/sql-lab.yaml" \
  --region "$AWS_REGION" \
  --no-fail-on-empty-changeset \
  --tags project=sql-lab \
  "$@"

echo ">> Stack outputs:"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$AWS_REGION" \
  --query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' --output table
