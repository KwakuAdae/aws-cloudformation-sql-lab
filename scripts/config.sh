#!/usr/bin/env bash
# Shared lab settings. Override any value by exporting it before running a script.
export AWS_REGION="${AWS_REGION:-us-east-1}"
export STACK_NAME="${STACK_NAME:-sql-lab}"
