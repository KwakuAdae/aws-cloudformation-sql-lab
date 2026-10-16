-- Solutions to sql/exercises/exercises.md

-- 1. Sports products, cheapest first
SELECT name, price FROM products WHERE category_id = 4 ORDER BY price;

-- 2. Customers who signed up in 2025-Q2
SELECT COUNT(*) AS q2_signups
FROM customers
WHERE signup_date >= '2025-04-01' AND signup_date < '2025-07-01';

-- 3. Out-of-stock products
SELECT name FROM products WHERE stock = 0 ORDER BY name;

-- 4. Countries with more than one customer
SELECT country, COUNT(*) AS customers
FROM customers
GROUP BY country
HAVING COUNT(*) > 1
ORDER BY customers DESC;

-- 5. Revenue of delivered orders
SELECT SUM(oi.quantity * oi.unit_price) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered';

-- 6. Every order with its total, biggest first
SELECT o.order_id, c.first_name || ' ' || c.last_name AS customer,
       SUM(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY o.order_id, customer
ORDER BY total DESC, o.order_id;

-- 7. Customer with the most orders
SELECT c.first_name || ' ' || c.last_name AS customer, COUNT(*) AS orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY customer
ORDER BY orders DESC
LIMIT 1;

-- 8. Distinct customers per category (excluding cancelled orders)
SELECT cat.name AS category, COUNT(DISTINCT o.customer_id) AS customers
FROM categories cat
JOIN products p     ON p.category_id = cat.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY cat.name
ORDER BY cat.name;

-- 9. Customers whose first order was in 2025-Q1
SELECT c.first_name, c.last_name, MIN(o.order_date) AS first_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MIN(o.order_date) < '2025-04-01'
ORDER BY first_order;

-- 10. Each customer's largest order and its date
WITH order_totals AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           SUM(oi.quantity * oi.unit_price) AS total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total DESC, order_date) AS rn
    FROM order_totals
)
SELECT c.first_name || ' ' || c.last_name AS customer, r.total AS largest_order, r.order_date
FROM ranked r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY largest_order DESC;
