#!/usr/bin/env bash
# Run SQL files or queries against the lab database.
#   ./scripts/run-sql.sh sql/lessons/01-select-basics.sql
#   ./scripts/run-sql.sh -q "SELECT * FROM products LIMIT 5"
set -euo pipefail
source "$(dirname "$0")/config.sh"

args=()
for a in "$@"; do
  if [[ "$a" == *.sql && -f "$a" ]]; then args+=(-f "$a"); else args+=("$a"); fi
done
python3 "$(dirname "$0")/run_sql.py" "${args[@]}"
