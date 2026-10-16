#!/usr/bin/env bash
# Step 2: Create the tables and load the sample data (safe to re-run: it resets the data).
set -euo pipefail
source "$(dirname "$0")/config.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 "${ROOT}/scripts/run_sql.py" \
  -f "${ROOT}/sql/01-schema.sql" \
  -f "${ROOT}/sql/02-seed-data.sql" \
  -q "SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
      UNION ALL SELECT 'categories', COUNT(*) FROM categories
      UNION ALL SELECT 'products', COUNT(*) FROM products
      UNION ALL SELECT 'orders', COUNT(*) FROM orders
      UNION ALL SELECT 'order_items', COUNT(*) FROM order_items"
