-- Lesson 1: SELECT basics: choosing columns, filtering, sorting and limiting rows

-- 1.1 Every column, every row
SELECT * FROM customers;

-- 1.2 Only the columns you need, with friendlier names (aliases)
SELECT first_name, last_name, country AS customer_country
FROM customers;

-- 1.3 Filter rows with WHERE
SELECT first_name, last_name, city
FROM customers
WHERE country = 'Ghana';

-- 1.4 Combine conditions with AND / OR, and use comparison operators
SELECT name, price, stock
FROM products
WHERE price < 50 AND stock > 0;

-- 1.5 IN, BETWEEN and LIKE
SELECT name, price FROM products WHERE category_id IN (1, 2);
SELECT order_id, order_date FROM orders WHERE order_date BETWEEN '2025-06-01' AND '2025-08-31';
SELECT first_name, email FROM customers WHERE email LIKE '%son@%';

-- 1.6 NULL needs IS NULL / IS NOT NULL (never = NULL)
SELECT first_name, last_name FROM customers WHERE city IS NULL;

-- 1.7 Sort with ORDER BY, and take the top rows with LIMIT
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- 1.8 Remove duplicates with DISTINCT
SELECT DISTINCT country FROM customers ORDER BY country;

-- 1.9 Calculated columns
SELECT name, price, stock, price * stock AS inventory_value
FROM products
ORDER BY inventory_value DESC;
