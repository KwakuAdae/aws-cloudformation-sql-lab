-- Lesson 3: JOINs: combining tables

-- 3.1 INNER JOIN: orders with the customer's name
SELECT o.order_id, o.order_date, c.first_name, c.last_name, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 3.2 Multi-table join: each line item with product and category
SELECT oi.order_id, p.name AS product, cat.name AS category, oi.quantity, oi.unit_price
FROM order_items oi
JOIN products   p   ON p.product_id   = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY oi.order_id, product;

-- 3.3 Revenue per customer (excluding cancelled orders)
SELECT c.first_name || ' ' || c.last_name AS customer,
       SUM(oi.quantity * oi.unit_price)  AS revenue
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY customer
ORDER BY revenue DESC;

-- 3.4 LEFT JOIN: every customer, even those with no orders
SELECT c.first_name, c.last_name, COUNT(o.order_id) AS orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY orders, c.last_name;

-- 3.5 Anti-join: products that have never been ordered
SELECT p.name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
ORDER BY p.name;

-- 3.6 Revenue by category
SELECT cat.name AS category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM categories cat
JOIN products p     ON p.category_id = cat.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY cat.name
ORDER BY revenue DESC;
