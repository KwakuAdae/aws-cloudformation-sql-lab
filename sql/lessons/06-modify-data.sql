-- Lesson 6: Changing data: INSERT, UPDATE, DELETE and RETURNING
-- Tip: run 02-seed-data.sql again (after 01-schema.sql) to reset the data at any time.

-- 6.1 Add a customer and see the generated id
INSERT INTO customers (first_name, last_name, email, city, country)
VALUES ('Kwame', 'Owusu', 'kwame.owusu@example.com', 'Takoradi', 'Ghana')
RETURNING customer_id, first_name, signup_date;

-- 6.2 Place an order for that customer (look the id up instead of hard-coding it)
INSERT INTO orders (customer_id, order_date, status)
SELECT customer_id, CURRENT_DATE, 'pending' FROM customers WHERE email = 'kwame.owusu@example.com'
RETURNING order_id;

-- 6.3 Add a line item to the newest order
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT MAX(order_id), 6, 1, 42.00 FROM orders;

-- 6.4 Restock out-of-stock products
UPDATE products
SET stock = 25
WHERE stock = 0
RETURNING name, stock;

-- 6.5 10% price increase for one category
UPDATE products
SET price = ROUND(price * 1.10, 2)
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'Books')
RETURNING name, price;

-- 6.6 Mark old shipped orders as delivered
UPDATE orders
SET status = 'delivered'
WHERE status = 'shipped' AND order_date < '2025-09-01'
RETURNING order_id, status;

-- 6.7 Delete the order we created (ON DELETE CASCADE removes its line items too)
DELETE FROM orders
WHERE customer_id = (SELECT customer_id FROM customers WHERE email = 'kwame.owusu@example.com')
RETURNING order_id;

DELETE FROM customers WHERE email = 'kwame.owusu@example.com' RETURNING customer_id;

-- 6.8 Constraints protect the data. Each of these fails on purpose (try them one at a time):
--   INSERT INTO products (name, category_id, price) VALUES ('Broken', 1, -5);        -- CHECK price >= 0
--   INSERT INTO orders (customer_id, order_date) VALUES (999, CURRENT_DATE);        -- FOREIGN KEY
--   INSERT INTO customers (first_name, last_name, email, country)
--     VALUES ('Dup', 'User', 'ama.mensah@example.com', 'Ghana');                     -- UNIQUE email
