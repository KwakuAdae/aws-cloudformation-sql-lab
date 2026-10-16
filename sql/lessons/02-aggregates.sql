-- Lesson 2: Aggregate functions, GROUP BY and HAVING

-- 2.1 Summary of the whole products table
SELECT COUNT(*)            AS product_count,
       MIN(price)          AS cheapest,
       MAX(price)          AS most_expensive,
       ROUND(AVG(price),2) AS average_price,
       SUM(stock)          AS units_in_stock
FROM products;

-- 2.2 Customers per country
SELECT country, COUNT(*) AS customers
FROM customers
GROUP BY country
ORDER BY customers DESC, country;

-- 2.3 Orders per status
SELECT status, COUNT(*) AS orders
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- 2.4 HAVING filters groups (WHERE filters rows before grouping)
SELECT customer_id, COUNT(*) AS orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 3
ORDER BY orders DESC;

-- 2.5 Orders per month
SELECT DATE_TRUNC('month', order_date)::date AS month, COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;

-- 2.6 Conditional counting with FILTER
SELECT COUNT(*)                                      AS total_orders,
       COUNT(*) FILTER (WHERE status = 'delivered')  AS delivered,
       COUNT(*) FILTER (WHERE status = 'cancelled')  AS cancelled
FROM orders;
