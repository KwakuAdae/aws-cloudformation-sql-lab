-- Lesson 4: Subqueries and Common Table Expressions (WITH)

-- 4.1 Subquery in WHERE: products priced above average
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 4.2 IN with a subquery: customers who bought a book
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (
    SELECT o.customer_id
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE p.category_id = (SELECT category_id FROM categories WHERE name = 'Books')
)
ORDER BY last_name;

-- 4.3 EXISTS: customers with at least one pending order
SELECT c.first_name, c.last_name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'pending')
ORDER BY c.last_name;

-- 4.4 CTE: order totals, then the average order value
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY o.order_id, o.customer_id
)
SELECT COUNT(*) AS orders, ROUND(AVG(total), 2) AS avg_order_value, MAX(total) AS biggest_order
FROM order_totals;

-- 4.5 Chained CTEs: customers who spend more than the average customer
WITH customer_spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY o.customer_id
),
average AS (
    SELECT AVG(spend) AS avg_spend FROM customer_spend
)
SELECT c.first_name, c.last_name, cs.spend
FROM customer_spend cs
JOIN customers c ON c.customer_id = cs.customer_id
CROSS JOIN average a
WHERE cs.spend > a.avg_spend
ORDER BY cs.spend DESC;

-- 4.6 CASE: label products by price band
SELECT name, price,
       CASE WHEN price < 25  THEN 'budget'
            WHEN price < 100 THEN 'mid-range'
            ELSE 'premium' END AS price_band
FROM products
ORDER BY price;
