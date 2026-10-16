-- Lesson 7: Views, indexes and query plans

-- 7.1 A view saves a query under a name you can SELECT from
CREATE OR REPLACE VIEW order_totals AS
SELECT o.order_id, o.order_date, o.status,
       c.first_name || ' ' || c.last_name AS customer,
       SUM(oi.quantity * oi.unit_price)   AS total
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY o.order_id, o.order_date, o.status, customer;

SELECT * FROM order_totals WHERE total > 100 ORDER BY total DESC;

-- 7.2 Inspect how PostgreSQL runs a query
EXPLAIN
SELECT * FROM orders WHERE order_date >= '2025-10-01';

-- 7.3 Add an index on order_date and compare the plan
-- (on a tiny table the planner may still choose a sequential scan, because it's cheaper)
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);

EXPLAIN
SELECT * FROM orders WHERE order_date >= '2025-10-01';

-- 7.4 List the indexes on a table
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders'
ORDER BY indexname;

-- 7.5 List all tables and views in the database
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_type, table_name;
