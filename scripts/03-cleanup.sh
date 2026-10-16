#!/usr/bin/env bash
# Step 3: Delete the stack and everything in it (database, VPC, secret). Data is not kept.
set -euo pipefail
source "$(dirname "$0")/config.sh"

echo ">> Deleting stack '${STACK_NAME}' (about 5-10 minutes)..."
aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$AWS_REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$AWS_REGION"
echo "✅ Stack deleted."
