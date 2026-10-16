-- =====================================================================
-- SQL Lab schema: a small online shop
--   customers 1──* orders 1──* order_items *──1 products *──1 categories
-- =====================================================================

DROP VIEW  IF EXISTS order_totals;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    city         VARCHAR(60),
    country      VARCHAR(60)  NOT NULL,
    signup_date  DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE categories (
    category_id  SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    name         VARCHAR(100)  NOT NULL,
    category_id  INT           NOT NULL REFERENCES categories(category_id),
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock        INT           NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT         NOT NULL REFERENCES customers(customer_id),
    order_date   DATE        NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items (
    order_id     INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id   INT           NOT NULL REFERENCES products(product_id),
    quantity     INT           NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
