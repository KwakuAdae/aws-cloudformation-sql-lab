-- Lesson 5: Window functions: calculations across related rows without collapsing them

-- 5.1 Rank products by price within each category
SELECT cat.name AS category, p.name, p.price,
       RANK() OVER (PARTITION BY p.category_id ORDER BY p.price DESC) AS price_rank
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY category, price_rank;

-- 5.2 Each customer's orders numbered in date order
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_number
FROM orders
ORDER BY customer_id, order_number;

-- 5.3 Running total of monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           SUM(oi.quantity * oi.unit_price)        AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY month
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- 5.4 Days since the customer's previous order (LAG)
SELECT customer_id, order_id, order_date,
       order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_previous
FROM orders
ORDER BY customer_id, order_date;

-- 5.5 Top-selling product in each category (filter on a window function with a CTE)
WITH product_sales AS (
    SELECT p.category_id, p.name, SUM(oi.quantity) AS units,
           RANK() OVER (PARTITION BY p.category_id ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category_id, p.name
)
SELECT cat.name AS category, ps.name AS top_product, ps.units
FROM product_sales ps
JOIN categories cat ON cat.category_id = ps.category_id
WHERE ps.rnk = 1
ORDER BY category;
